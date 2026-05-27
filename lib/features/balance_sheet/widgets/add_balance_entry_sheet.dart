import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../investments/widgets/compact_calculator_keyboard.dart';
import '../models/balance_sheet_model.dart';
import '../services/balance_sheet_service.dart';

class AddBalanceEntrySheet extends StatefulWidget {
  final String entryType; // 'ASSET' or 'LIABILITY'
  final BalanceSheetModel?
      entryToEdit; // [NEW] Optional parameter for Edit Mode

  const AddBalanceEntrySheet(
      {super.key, required this.entryType, this.entryToEdit});

  @override
  State<AddBalanceEntrySheet> createState() => _AddBalanceEntrySheetState();
}

class _AddBalanceEntrySheetState extends State<AddBalanceEntrySheet> {
  final _service = GetIt.I<BalanceSheetService>();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String _title = '';
  String _category = ''; // [FIX] Start empty, no default selection
  String _notes = '';
  String? _contactName;
  DateTime? _dueDate;

  String? _amountError;
  String? _categoryError; // [FIX] Added to track category validation

  late List<String> _categories;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Comprehensive Categories
    if (widget.entryType == 'ASSET') {
      _categories = [
        'Receivables',
        'Bank Accounts',
        'Emergency Fund',
        'Money Lent',
        'Asset Lent', // Explicitly added Asset Lent
        'Interest Receivable', // [NEW]
        'Cash',
        'Stocks & Mutual Funds',
        'Bonds & FDs',
        'PF / Gratuity',
        'Crypto',
        'Real Estate',
        'Vehicles',
        'Jewelry & Gold',
        'Collectibles',
        'Business Assets',
        'Security Deposits',
        'Life Insurance',
        'Retirement Accounts',
        'Prepayments',
        'Other Assets'
      ];
    } else {
      _categories = [
        'Payables',
        'Buy Now Pay Later',
        'Money Borrowed',
        'Asset Borrowed', // Explicitly added Asset Borrowed
        'Interest Payable', // [NEW]
        'Personal Loans',
        'EMI / Consumer Loans',
        'Mortgages',
        'Student Loans',
        'Auto Loans',
        'Business Loans',
        'Overdrafts',
        'Credit Cards',
        'Unpaid Bills',
        'Taxes Owed',
        'Medical Debt',
        'Margin Loans',
        'Other Liabilities'
      ];
    }

    // 2. Check if Edit Mode and Populate Data
    if (widget.entryToEdit != null) {
      _isEditMode = true;
      final e = widget.entryToEdit!;
      _title = e.title;
      _amountController.text = e.amount
          .toString()
          .replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""); // Clean decimals

      // Ensure category exists in list, otherwise append it
      if (!_categories.contains(e.category)) {
        _categories.add(e.category);
      }
      _category = e.category;
      _notes = e.notes ?? '';
      _selectedDate = e.date;
      _contactName = e.contactName;
      _dueDate = e.dueDate;
    }

    _amountController.addListener(() {
      if (_amountError != null && _amountController.text.isNotEmpty) {
        setState(() => _amountError = null);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _evaluateFinalAmount() {
    try {
      final expression =
          _amountController.text.replaceAll('×', '*').replaceAll('÷', '/');
      if (expression.isEmpty) return null;
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickDate(Color themeColor, {required bool isDueDate}) async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate
          ? (_dueDate ?? DateTime.now().add(const Duration(days: 30)))
          : _selectedDate,
      firstDate: isDueDate ? DateTime.now() : DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
                primary: themeColor,
                onPrimary: Colors.black,
                surface: BudgetrColors.cardSurface)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          // [FEATURE 7 FIX] Set explicitly to 23:59:59 to prevent early overdue triggers
          _dueDate =
              DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        } else {
          _selectedDate = DateTime(picked.year, picked.month, picked.day);
        }
      });
    }
  }

  Future<void> _saveEntry() async {
    HapticFeedback.mediumImpact();

    final amount = _evaluateFinalAmount();
    bool isAmountValid = amount != null && amount > 0;

    // [FIX] Validate Category
    bool isCategoryValid = _category.isNotEmpty;

    setState(() {
      _amountError = isAmountValid ? null : "Please enter a valid amount.";
      _categoryError = isCategoryValid ? null : "Please select a category.";
    });

    bool isFormValid = _formKey.currentState!.validate();

    if (!isAmountValid || !isCategoryValid || !isFormValid) {
      HapticFeedback.heavyImpact();
      return;
    }

    _formKey.currentState!.save();

    final entry = BalanceSheetModel(
      id: _isEditMode ? widget.entryToEdit!.id : '', // Preserve ID if editing
      title: _title,
      amount: amount,
      entryType: widget.entryType,
      category: _category,
      date: _selectedDate,
      notes: _notes.isNotEmpty ? _notes : null,
      contactName: _contactName,
      dueDate: _dueDate,
      isSettled: _isEditMode ? widget.entryToEdit!.isSettled : false,
      // Ensure we preserve partial settlement during edit
      settledAmount: _isEditMode ? widget.entryToEdit!.settledAmount : 0.0,
    );

    if (_isEditMode) {
      await _service.updateEntry(entry);
    } else {
      await _service.addEntry(entry);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showCategoryPicker(Color themeColor) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height *
                0.7, // Increased height for more categories
            decoration: const BoxDecoration(
              color: BudgetrColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Text("SELECT CATEGORY",
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: BudgetrColors.cardSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.05),
                          indent: 16,
                          endIndent: 16),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _category;
                        return InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _category = cat;
                              _categoryError =
                                  null; // [FIX] Clear error on select
                            });
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat,
                                    style: TextStyle(
                                        color: isSelected
                                            ? themeColor
                                            : Colors.white,
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500)),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded,
                                      color: themeColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAsset = widget.entryType == 'ASSET';
    final Color themeColor =
        isAsset ? BudgetrColors.success : BudgetrColors.error;

    // Dynamic Title based on mode
    final String sheetTitle = _isEditMode
        ? (isAsset ? "EDIT ASSET" : "EDIT LIABILITY")
        : (isAsset ? "RECORD ASSET" : "RECORD LIABILITY");

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 16),

            // Premium Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            shape: BoxShape.circle),
                        child: Icon(
                            _isEditMode
                                ? Icons.edit_rounded
                                : (isAsset
                                    ? Icons.add_rounded
                                    : Icons.remove_rounded),
                            color: themeColor,
                            size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(sheetTitle,
                          style: TextStyle(
                              color: themeColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _pickDate(themeColor, isDueDate: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: BudgetrColors.cardSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.05))),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded,
                              color: themeColor.withOpacity(0.8), size: 14),
                          const SizedBox(width: 6),
                          Text(DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scrollable Middle Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Amount Display
                    TextFormField(
                      controller: _amountController,
                      autofocus: !_isEditMode, // Don't auto-focus if editing
                      readOnly: true,
                      showCursor: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _amountError != null
                              ? BudgetrColors.error
                              : Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          shadows: [
                            Shadow(
                                color: (_amountError != null
                                        ? BudgetrColors.error
                                        : themeColor)
                                    .withOpacity(0.2),
                                blurRadius: 15)
                          ]),
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: const TextStyle(
                            color: Colors.white24,
                            fontSize: 48,
                            fontWeight: FontWeight.w900),
                        prefixText: "₹ ",
                        prefixStyle: TextStyle(
                            color: _amountError != null
                                ? BudgetrColors.error
                                : themeColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: _amountError == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(_amountError!,
                                  style: const TextStyle(
                                      color: BudgetrColors.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5))),
                    ),
                    const SizedBox(height: 32),

                    // Unified Settings-Style Form Block
                    Container(
                      decoration: BoxDecoration(
                          color: BudgetrColors.cardSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.05))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompactInputRow(
                              icon: Icons.edit_note_rounded,
                              hint: "Title (e.g., Loan to Alex)",
                              initialValue: _title,
                              onSaved: (val) => _title = val!,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null),
                          Divider(
                              height: 1,
                              color: Colors.white.withOpacity(0.05),
                              indent: 48),

                          // --- [FIX] CATEGORY SELECTION UI ---
                          InkWell(
                            onTap: () => _showCategoryPicker(themeColor),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.category_rounded,
                                      color: _categoryError != null
                                          ? BudgetrColors.error
                                          : themeColor.withOpacity(0.7),
                                      size: 20),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Text(
                                          _category.isEmpty
                                              ? "Select Category"
                                              : _category,
                                          style: TextStyle(
                                              color: _category.isEmpty
                                                  ? Colors.white38
                                                  : Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500))),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Colors.white24, size: 20),
                                ],
                              ),
                            ),
                          ),
                          // Inline Error for Category
                          if (_categoryError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 52, bottom: 8),
                              child: Text(
                                _categoryError!,
                                style: const TextStyle(
                                  color: BudgetrColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Divider(
                              height: 1,
                              color: Colors.white.withOpacity(0.05),
                              indent: 48),

                          // Contact Field (Always available)
                          _buildCompactInputRow(
                              icon: Icons.person_rounded,
                              hint: isAsset
                                  ? "Who owes you? (Optional)"
                                  : "Who do you owe? (Optional)",
                              initialValue: _contactName,
                              onSaved: (val) => _contactName =
                                  (val != null && val.trim().isNotEmpty)
                                      ? val.trim()
                                      : null),
                          Divider(
                              height: 1,
                              color: Colors.white.withOpacity(0.05),
                              indent: 48),

                          // Due Date Field
                          InkWell(
                            onTap: () => _pickDate(themeColor, isDueDate: true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.event_available_rounded,
                                      color: themeColor.withOpacity(0.7),
                                      size: 20),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Text(
                                          _dueDate != null
                                              ? "Due: ${DateFormat('MMM dd, yyyy').format(_dueDate!)}"
                                              : "Set Due Date (Optional)",
                                          style: TextStyle(
                                              color: _dueDate != null
                                                  ? Colors.white
                                                  : Colors.white38,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500))),
                                  if (_dueDate != null)
                                    GestureDetector(
                                        onTap: () =>
                                            setState(() => _dueDate = null),
                                        child: const Icon(Icons.close_rounded,
                                            color: Colors.white38, size: 20))
                                  else
                                    const Icon(Icons.chevron_right_rounded,
                                        color: Colors.white24, size: 20),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                              height: 1,
                              color: Colors.white.withOpacity(0.05),
                              indent: 48),

                          _buildCompactInputRow(
                              icon: Icons.sticky_note_2_rounded,
                              hint: "Notes (Optional)",
                              initialValue: _notes,
                              onSaved: (val) => _notes = val ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section (Keyboard & Action)
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, isKeyboardOpen ? bottomInset + 16 : 24),
              decoration: BoxDecoration(
                  color: BudgetrColors.background,
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isKeyboardOpen) ...[
                    CompactCalculatorKeyboard(controller: _amountController),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text(
                          _isEditMode ? "SAVE CHANGES" : "CONFIRM ENTRY",
                          style: TextStyle(
                              color: isAsset
                                  ? const Color(0xFF0A0E12)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInputRow(
      {required IconData icon,
      required String hint,
      String? initialValue,
      required FormFieldSetter<String> onSaved,
      FormFieldValidator<String>? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                      color: Colors.white24,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12)),
              validator: validator,
              onSaved: onSaved,
            ),
          ),
        ],
      ),
    );
  }
}
