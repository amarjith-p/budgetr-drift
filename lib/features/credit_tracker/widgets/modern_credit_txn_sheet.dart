import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

// --- CORE IMPORTS ---
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

// --- FEATURE IMPORTS ---
import '../../settings/services/settings_service.dart';
import '../../dashboard/services/dashboard_service.dart'; // Added
import '../../settlement/services/settlement_service.dart'; // Added
import '../models/credit_models.dart';
import '../services/credit_service.dart';

class ModernCreditTxnSheet extends StatefulWidget {
  final CreditTransactionModel? transactionToEdit;

  const ModernCreditTxnSheet({super.key, this.transactionToEdit});

  @override
  State<ModernCreditTxnSheet> createState() => _ModernCreditTxnSheetState();
}

class _ModernCreditTxnSheetState extends State<ModernCreditTxnSheet> {
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERS ---
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final FocusNode _amountNode = FocusNode();
  final FocusNode _notesNode = FocusNode();

  // --- LOGIC STATE ---
  bool _isLinked = false; // Locks Type & Card if true
  bool _attemptedSave = false;
  bool _isMonthSettled = false; // [NEW] Closed Budget Check

  // Selections
  CreditCardModel? _selectedCard;

  // Data lists
  List<CreditCardModel> _cards = [];
  List<String> _buckets = [];
  List<String> _globalFallbackBuckets = []; // [NEW] Store default buckets
  List<TransactionCategoryModel> _allCategories = [];

  // Fields
  DateTime _date = DateTime.now();
  String _type = 'Expense'; // 'Expense' or 'Income' (Payment)
  String? _selectedBucket;
  String? _category;
  String? _subCategory;

  bool _isLoading = false;
  bool _showCalculator = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Toggle Calculator visibility based on focus
    _notesNode.addListener(() {
      if (_notesNode.hasFocus) {
        setState(() => _showCalculator = false);
      } else {
        setState(() => _showCalculator = true);
      }
    });

    _amountNode.addListener(() {
      if (_amountNode.hasFocus) {
        setState(() => _showCalculator = true);
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _amountNode.dispose();
    _notesNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 1. DATA & LOGIC
  // ===========================================================================

  Future<void> _loadData() async {
    final cardsFuture = GetIt.I<CreditService>().getCreditCards().first;
    final catsFuture = GetIt.I<CategoryService>().getCategories().first;
    final configFuture = GetIt.I<SettingsService>().getPercentageConfig();

    final results = await Future.wait([
      cardsFuture,
      catsFuture,
      configFuture,
    ]);

    if (mounted) {
      // 1. Parse Global Config Buckets
      final config = results[2] as dynamic;
      _globalFallbackBuckets =
          (config.categories as List).map((e) => e.name as String).toList();
      _globalFallbackBuckets.add('Out of Bucket');

      setState(() {
        _cards = results[0] as List<CreditCardModel>;
        _allCategories = results[1] as List<TransactionCategoryModel>;

        // 2. Populate if Editing
        if (widget.transactionToEdit != null) {
          final t = widget.transactionToEdit!;
          _amountCtrl.text =
              t.amount.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
          _notesCtrl.text = t.notes;
          _date = t.date;
          _type = t.type;
          _selectedBucket = t.bucket;
          _category = t.category;
          _subCategory = t.subCategory;

          try {
            _selectedCard = _cards.firstWhere((c) => c.id == t.cardId);
          } catch (e) {
            _selectedCard = null;
          }

          // Check Linked Status
          if (t.linkedExpenseId != null && t.linkedExpenseId!.isNotEmpty) {
            _isLinked = true;
          }
        } else {
          // Defaults for new entry
          if (_cards.isNotEmpty) _selectedCard = _cards.first;
        }
      });

      // [NEW] Trigger Date/Settlement Check
      await _updateBucketsForDate(_date);
    }
  }

  // [NEW] Smart Bucket Logic & Settlement Check
  Future<void> _updateBucketsForDate(DateTime date) async {
    try {
      // 1. Check if Month is Settled (Closed)
      final isSettled = await GetIt.I<SettlementService>()
          .isMonthSettled(date.year, date.month);

      if (isSettled) {
        setState(() {
          _isMonthSettled = true;
          _buckets = ['Out of Bucket'];
          _selectedBucket = 'Out of Bucket';
        });
        return;
      }

      // 2. Fetch Historical Bucket Order for that Month
      final record = await GetIt.I<DashboardService>()
          .getRecordForMonth(date.year, date.month);

      List<String> newBuckets = [];
      if (record != null && record.bucketOrder.isNotEmpty) {
        newBuckets = List.from(record.bucketOrder);
        // Ensure all allocations exist
        for (var key in record.allocations.keys) {
          if (!newBuckets.contains(key)) newBuckets.add(key);
        }
      } else if (record != null) {
        // Fallback: Sort by allocation amount
        final sorted = record.allocations.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        newBuckets = sorted.map((e) => e.key).toList();
      } else {
        // Fallback: Global Config
        newBuckets = List.from(_globalFallbackBuckets);
      }

      if (!newBuckets.contains('Out of Bucket')) {
        newBuckets.add('Out of Bucket');
      }

      setState(() {
        _isMonthSettled = false;
        _buckets = newBuckets;
        // Reset selection if it doesn't exist in new list (unless logic dictates otherwise)
        if (_selectedBucket != null && !_buckets.contains(_selectedBucket)) {
          _selectedBucket = null;
        }
      });
    } catch (e) {
      // Safety Fallback
      setState(() => _buckets = List.from(_globalFallbackBuckets));
    }
  }

  // --- SAVE LOGIC ---
  Future<void> _save() async {
    setState(() => _attemptedSave = true);

    // 1. Amount Validation
    final double amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      _showError("Amount must be greater than 0");
      return;
    }

    // 2. Card Validation
    if (_selectedCard == null) {
      _showError("Please select a Credit Card");
      return;
    }

    // 3. Bucket Validation (Expense Only)
    if (_type == 'Expense' && _selectedBucket == null) {
      _showError("Please select a Bucket");
      return;
    }

    // 4. Category Validation
    if (_category == null) {
      _showError("Please select a Category");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final txn = CreditTransactionModel(
        id: widget.transactionToEdit?.id ?? '',
        cardId: _selectedCard!.id,
        amount: amount,
        date: Timestamp.fromDate(_date),
        bucket: _type == 'Expense'
            ? (_selectedBucket ?? 'Unallocated')
            : 'Unallocated',
        type: _type,
        category: _category!,
        subCategory: _subCategory ?? 'General',
        notes: _notesCtrl.text,
        linkedExpenseId: widget.transactionToEdit?.linkedExpenseId,
      );

      if (widget.transactionToEdit == null) {
        // Add
        await GetIt.I<CreditService>().addTransaction(txn);
        if (mounted) {
          await BudgetNotificationService()
              .checkAndTriggerCreditNotification(txn);
        }
      } else {
        // Update
        await GetIt.I<CreditService>().updateTransaction(txn);
        if (mounted) {
          await BudgetNotificationService()
              .checkAndTriggerCreditNotification(txn);
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showStatusSheet(
      context: context,
      title: "Validation Error",
      message: msg,
      icon: Icons.warning_amber_rounded,
      color: BudgetrColors.error,
    );
  }

  Future<void> _pickDate() async {
    _amountNode.unfocus();
    _notesNode.unfocus();
    final d = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));

    if (d != null) {
      if (!mounted) return;
      final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_date),
          builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));

      if (t != null) {
        final newDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        setState(() => _date = newDate);
        // [NEW] Update buckets when date changes
        await _updateBucketsForDate(newDate);
      }
    }
  }

  // ===========================================================================
  // 2. DESIGN & LAYOUT
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // Colors based on Type
    Color typeColor =
        _type == 'Expense' ? BudgetrColors.error : BudgetrColors.success;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        decoration: const BoxDecoration(
          color: BudgetrColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),

                  // LINKED WARNING
                  if (_isLinked)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.link,
                              color: Colors.blueAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Synced Transaction: Type and Card are locked.",
                              style: BudgetrStyles.caption.copyWith(
                                  color: Colors.blueAccent, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // [NEW] SETTLED WARNING
                  if (_isMonthSettled && _type == 'Expense')
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orangeAccent.withOpacity(0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_clock,
                              color: Colors.orangeAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Budget Closed: Expenses forced to 'Out of Bucket'.",
                              style: BudgetrStyles.caption.copyWith(
                                  color: Colors.orangeAccent, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Segment Control (Expense vs Payment)
                  Container(
                    height: 36,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        _buildSegment("Expense", Colors.redAccent),
                        _buildSegment("Income", Colors.greenAccent,
                            labelOverride: "Payment"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Date Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(DateFormat('MMM dd, hh:mm a').format(_date),
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Hero Amount
            _buildHeroAmount(typeColor),

            // 4. MAIN FORM GRID
            Flexible(
              fit: FlexFit.loose,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMainGrid(),

                      const SizedBox(height: 12),

                      // Notes
                      TextFormField(
                        controller: _notesCtrl,
                        focusNode: _notesNode,
                        style: BudgetrStyles.body.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Add a note...",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.3)),
                          prefixIcon: Icon(Icons.edit_note,
                              color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Calculator & Save
            if (_showCalculator) ...[
              Container(color: Colors.white.withOpacity(0.05), height: 1),
              _EmbeddedCalculator(
                  controller: _amountCtrl, typeColor: typeColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const ModernLoader(size: 20)
                        : const Text("SAVE TRANSACTION",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                color: BudgetrColors.cardSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    child: const Text("Done")),
              )
            ]
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeroAmount(Color typeColor) {
    final bool hasError =
        _attemptedSave && (double.tryParse(_amountCtrl.text) ?? 0) <= 0;
    final Color displayColor = hasError ? Colors.redAccent : typeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: IntrinsicWidth(
        child: TextFormField(
          controller: _amountCtrl,
          focusNode: _amountNode,
          readOnly: true, // Use calculator
          showCursor: true,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: displayColor,
              height: 1.1),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "0",
              hintStyle: TextStyle(color: Colors.white12),
              prefixText: "₹",
              prefixStyle: TextStyle(
                  fontSize: 44,
                  color: hasError ? Colors.redAccent : Colors.white24,
                  fontWeight: FontWeight.w300),
              contentPadding: EdgeInsets.zero),
          onTap: () => FocusScope.of(context).requestFocus(_amountNode),
        ),
      ),
    );
  }

  Widget _buildSegment(String value, Color color, {String? labelOverride}) {
    final isSelected = _type == value;
    final isDisabled = _isLinked; // Lock if linked

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  _type = value;
                  // Reset bucket for Income as it's usually not bucketed in same way
                  if (_type == 'Income') _selectedBucket = null;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
          ),
          alignment: Alignment.center,
          child: Text(labelOverride ?? value,
              style: TextStyle(
                  color: isDisabled
                      ? Colors.white24
                      : (isSelected ? color : Colors.white38),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildMainGrid() {
    List<Widget> gridItems = [];

    // 1. Credit Card
    bool cardError = _attemptedSave && _selectedCard == null;
    gridItems.add(_buildGridItem(
        label: "CARD",
        value: _selectedCard?.name ?? "Select Card",
        icon: Icons.credit_card,
        isActive: !_isLinked,
        hasError: cardError,
        onTap: () {
          _showSelectionSheet<CreditCardModel>(
              "Select Card",
              _cards,
              _selectedCard,
              (c) => "${c.bankName} - ${c.name}",
              (v) => setState(() => _selectedCard = v));
        }));

    // 2. Category
    bool catError = _attemptedSave && _category == null;
    gridItems.add(_buildGridItem(
        label: "CATEGORY",
        value: _category ?? "Select",
        icon: Icons.category_outlined,
        isActive: true,
        hasError: catError,
        onTap: () {
          final relevantCats =
              _allCategories.where((c) => c.type == _type).toList();
          _showSelectionSheet<TransactionCategoryModel>(
              "Category",
              relevantCats,
              null,
              (c) => c.name,
              (v) => setState(() {
                    _category = v.name;
                    _subCategory = null; // Reset sub
                  }));
        }));

    // 3. Bucket (Active only for Expense)
    bool bucketActive = _type == 'Expense';
    bool bucketError =
        _attemptedSave && bucketActive && _selectedBucket == null;

    gridItems.add(_buildGridItem(
        label: "BUCKET",
        value: bucketActive ? (_selectedBucket ?? "Select") : "---",
        icon: Icons.pie_chart_outline,
        isActive: bucketActive,
        hasError: bucketError,
        onTap: () => _showSelectionSheet<String>(
            "Bucket",
            _buckets,
            _selectedBucket,
            (s) => s,
            (v) => setState(() => _selectedBucket = v))));

    // 4. Sub-Category
    String subVal = "---";
    bool subActive = _category != null;
    TransactionCategoryModel? catModel;

    if (_category != null) {
      try {
        catModel = _allCategories.firstWhere((c) => c.name == _category);
        if (catModel.subCategories.isNotEmpty) {
          subVal = _subCategory ?? "Select";
        } else {
          subActive = false;
        }
      } catch (_) {
        subActive = false;
      }
    }

    gridItems.add(_buildGridItem(
        label: "SUB-CATEGORY",
        value: subVal,
        icon: Icons.subdirectory_arrow_right,
        isActive: subActive,
        hasError: false,
        onTap: () {
          if (catModel != null) {
            _showSelectionSheet<String>(
                "Sub Category",
                catModel.subCategories,
                _subCategory,
                (s) => s,
                (v) => setState(() => _subCategory = v));
          }
        }));

    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: gridItems
            .map((item) =>
                SizedBox(width: (constraints.maxWidth - 12) / 2, child: item))
            .toList(),
      );
    });
  }

  Widget _buildGridItem(
      {required String label,
      required String value,
      required IconData icon,
      required bool isActive,
      required bool hasError,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasError
                  ? Colors.redAccent
                  : (isActive
                      ? Colors.white.withOpacity(0.08)
                      : Colors.transparent)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon,
                size: 14, color: isActive ? Colors.white38 : Colors.white12),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.white38 : Colors.white12,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 6),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.white24,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  void _showSelectionSheet<T>(String title, List<T> items, T? selected,
      String Function(T) labelGen, Function(T) onSel) {
    _amountNode.unfocus();
    _notesNode.unfocus();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: BudgetrColors.cardSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2))),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(title,
                          style:
                              BudgetrStyles.h2.copyWith(color: Colors.white))),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        bool isSelected = false;
                        if (selected != null) {
                          if (item is CreditCardModel &&
                              selected is CreditCardModel) {
                            isSelected = item.id == selected.id;
                          } else {
                            isSelected = item == selected;
                          }
                        }
                        return ListTile(
                          onTap: () {
                            onSel(item);
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          tileColor: isSelected
                              ? BudgetrColors.accent.withOpacity(0.1)
                              : Colors.white.withOpacity(0.03),
                          leading: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: BudgetrColors.accent)
                              : const Icon(Icons.circle_outlined,
                                  color: Colors.white24),
                          title: Text(labelGen(item),
                              style: TextStyle(
                                  color: isSelected
                                      ? BudgetrColors.accent
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ));
  }
}

// ===========================================================================
// 3. EMBEDDED CALCULATOR (Shared Design)
// ===========================================================================

class _EmbeddedCalculator extends StatelessWidget {
  final TextEditingController controller;
  final Color typeColor;

  const _EmbeddedCalculator(
      {required this.controller, required this.typeColor});

  void _onKey(String value) {
    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, value);
    controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + value.length));
  }

  void _onBackspace() {
    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    if (start > 0) {
      final newText = text.replaceRange(start - 1, start, '');
      controller.value = TextEditingValue(
          text: newText, selection: TextSelection.collapsed(offset: start - 1));
    }
  }

  void _onClear() {
    controller.clear();
  }

  void _onEquals() {
    String expression =
        controller.text.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      controller.text =
          result.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    } catch (e) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff121212),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            _key('C', color: Colors.redAccent, onTap: _onClear),
            _key('(', color: Colors.white54),
            _key(')', color: Colors.white54),
            _key('÷', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('7'),
            _key('8'),
            _key('9'),
            _key('×', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('4'),
            _key('5'),
            _key('6'),
            _key('-', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('1'),
            _key('2'),
            _key('3'),
            _key('+', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('.', color: Colors.white70),
            _key('0'),
            _backspaceKey(),
            _equalsKey(typeColor)
          ]),
        ],
      ),
    );
  }

  Widget _key(String label, {Color? color, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap ?? () => _onKey(label),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.white)),
        ),
      ),
    );
  }

  Widget _backspaceKey() {
    return Expanded(
      child: InkWell(
        onTap: _onBackspace,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.backspace_outlined,
              size: 18, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _equalsKey(Color color) {
    return Expanded(
      child: InkWell(
        onTap: _onEquals,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
          child: Text('=',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    );
  }
}
