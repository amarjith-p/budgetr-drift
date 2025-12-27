import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart'; // Local Auth

import '../../../core/constants/firebase_constants.dart'; // Firebase Constants
import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/models/percentage_config_model.dart';
import '../services/dashboard_service.dart';
import '../../settings/services/settings_service.dart';

class AddRecordSheet extends StatefulWidget {
  final FinancialRecord? recordToEdit;
  final DateTime? initialDate;

  const AddRecordSheet({super.key, this.recordToEdit, this.initialDate});

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _dashboardService = DashboardService();
  final _settingsService = SettingsService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final ScrollController _scrollController = ScrollController();
  final LocalAuthentication _auth = LocalAuthentication(); // Auth Instance

  // Theme
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF3A86FF);

  // Controllers
  late TextEditingController _salaryController;
  late TextEditingController _extraIncomeController;
  late TextEditingController _emiController;

  final FocusNode _salaryFocus = FocusNode();
  final FocusNode _extraFocus = FocusNode();
  final FocusNode _emiFocus = FocusNode();

  int? _selectedYear;
  int? _selectedMonth;
  final List<int> _years = List.generate(
    10,
    (index) => DateTime.now().year - 2 + index,
  );
  final List<int> _months = List.generate(12, (index) => index + 1);

  double _effectiveIncome = 0;
  PercentageConfig? _config;

  // Keyboard
  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.recordToEdit != null;

    _salaryController = TextEditingController(
      text: widget.recordToEdit?.salary.toString() ?? '',
    );
    _extraIncomeController = TextEditingController(
      text: widget.recordToEdit?.extraIncome.toString() ?? '',
    );
    _emiController = TextEditingController(
      text: widget.recordToEdit?.emi.toString() ?? '',
    );

    _initializeConfig();

    _salaryController.addListener(_calculate);
    _extraIncomeController.addListener(_calculate);
    _emiController.addListener(_calculate);
  }

  Future<void> _initializeConfig() async {
    final masterConfig = await _settingsService.getPercentageConfig();

    if (_isEditing) {
      _selectedYear = widget.recordToEdit!.year;
      _selectedMonth = widget.recordToEdit!.month;

      // MERGE LOGIC: Respect Master Order, preserve historic values
      List<CategoryConfig> mergedCategories = [];

      // 1. Add categories from Master Config that exist in Record
      for (var masterCat in masterConfig.categories) {
        if (widget.recordToEdit!.allocationPercentages.containsKey(
          masterCat.name,
        )) {
          mergedCategories.add(
            CategoryConfig(
              name: masterCat.name,
              percentage:
                  widget.recordToEdit!.allocationPercentages[masterCat.name]!,
            ),
          );
        }
      }

      // 2. Add remaining categories from Record that weren't in Master Config (Legacy buckets)
      widget.recordToEdit!.allocationPercentages.forEach((key, val) {
        if (!mergedCategories.any((c) => c.name == key)) {
          mergedCategories.add(CategoryConfig(name: key, percentage: val));
        }
      });

      setState(() {
        _config = PercentageConfig(categories: mergedCategories);
        _calculate();
      });
    } else {
      // Use the passed initialDate (from Dashboard) or fallback to Now
      final date = widget.initialDate ?? DateTime.now();
      _selectedYear = date.year;
      _selectedMonth = date.month;
      setState(() {
        _config = masterConfig;
      });
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _extraIncomeController.dispose();
    _emiController.dispose();
    _salaryFocus.dispose();
    _extraFocus.dispose();
    _emiFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_config == null) return;
    final salary = double.tryParse(_salaryController.text) ?? 0;
    final extra = double.tryParse(_extraIncomeController.text) ?? 0;
    final emi = double.tryParse(_emiController.text) ?? 0;

    setState(() {
      _effectiveIncome = (salary + extra) - emi;
      if (_effectiveIncome < 0) _effectiveIncome = 0;
    });
  }

  // --- Keyboard Handling ---
  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeController = ctrl;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
    _scrollToInput(node);
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _handleNext() {
    if (_activeController == _salaryController)
      _setActive(_extraIncomeController, _extraFocus);
    else if (_activeController == _extraIncomeController)
      _setActive(_emiController, _emiFocus);
    else
      _closeKeyboard();
  }

  // --- NEW: Handle Previous Field ---
  void _handlePrevious() {
    if (_activeController == _emiController)
      _setActive(_extraIncomeController, _extraFocus);
    else if (_activeController == _extraIncomeController)
      _setActive(_salaryController, _salaryFocus);
    else
      _closeKeyboard();
  }

  Future<void> _save() async {
    _closeKeyboard();
    if (_config == null) return;
    if (_salaryController.text.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: const Text(
              "Validation Error",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Salary is required.",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("OK", style: TextStyle(color: _accentColor)),
              ),
            ],
          ),
        );
      }
      return;
    }

    final idString =
        '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';

    // --- SMART SECURITY CHECK ---
    try {
      // 1. Check if record actually exists in DB
      final docSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.financialRecords)
          .doc(idString)
          .get();

      // 2. Only authenticate if we are overwriting/updating existing data
      if (docSnapshot.exists) {
        bool authenticated = false;
        try {
          authenticated = await _auth.authenticate(
            localizedReason: 'Authenticate to update existing budget',
            options: const AuthenticationOptions(stickyAuth: true),
          );
        } on PlatformException catch (_) {
          // Handle auth errors (user cancelled, etc.)
          return;
        }

        if (!authenticated) {
          if (mounted) {
            // FIX: Use showDialog instead of SnackBar so it appears OVER the BottomSheet
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: _bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                title: const Text(
                  "Authentication Failed",
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  "Authentication is required to update an existing budget record.",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text("OK", style: TextStyle(color: _accentColor)),
                  ),
                ],
              ),
            );
          }
          return; // Abort Save
        }
      }
    } catch (e) {
      // Handle network/firestore errors gracefully with a Dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: const Text("Error", style: TextStyle(color: Colors.white)),
            content: Text(
              "Error checking record: $e",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("OK", style: TextStyle(color: _accentColor)),
              ),
            ],
          ),
        );
      }
      return;
    }
    // --- END SECURITY CHECK ---

    // Calculate Allocations using the ORDERED config
    Map<String, double> allocations = {};
    Map<String, double> percentages = {};
    for (var cat in _config!.categories) {
      allocations[cat.name] = _effectiveIncome * (cat.percentage / 100.0);
      percentages[cat.name] = cat.percentage;
    }

    final record = FinancialRecord(
      id: idString,
      salary: double.tryParse(_salaryController.text) ?? 0,
      extraIncome: double.tryParse(_extraIncomeController.text) ?? 0,
      emi: double.tryParse(_emiController.text) ?? 0,
      year: _selectedYear!,
      month: _selectedMonth!,
      effectiveIncome: _effectiveIncome,
      allocations: allocations,
      allocationPercentages: percentages,
      // Preserve creation, set update to Now
      createdAt: widget.recordToEdit?.createdAt ?? Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await _dashboardService.setFinancialRecord(record);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null) return const Center(child: ModernLoader());

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: _bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header with Date Pickers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'Edit Budget' : 'New Budget',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Date selection disabled during Edit
                      Row(
                        children: [
                          // Year Pill
                          GestureDetector(
                            onTap: _isEditing
                                ? null
                                : () => showSelectionSheet<int>(
                                    context: context,
                                    title: 'Select Year',
                                    items: _years,
                                    labelBuilder: (y) => y.toString(),
                                    onSelect: (v) =>
                                        setState(() => _selectedYear = v),
                                    selectedItem: _selectedYear,
                                  ),
                            child: Opacity(
                              opacity: _isEditing ? 0.5 : 1.0,
                              child: _datePill(_selectedYear.toString()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Month Pill
                          GestureDetector(
                            onTap: _isEditing
                                ? null
                                : () => showSelectionSheet<int>(
                                    context: context,
                                    title: 'Select Month',
                                    items: _months,
                                    labelBuilder: (m) => DateFormat(
                                      'MMM',
                                    ).format(DateTime(0, m)),
                                    onSelect: (v) =>
                                        setState(() => _selectedMonth = v),
                                    selectedItem: _selectedMonth,
                                  ),
                            child: Opacity(
                              opacity: _isEditing ? 0.5 : 1.0,
                              child: _datePill(
                                DateFormat(
                                  'MMM',
                                ).format(DateTime(0, _selectedMonth!)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildInput(
                    "Base Salary",
                    _salaryController,
                    _salaryFocus,
                    const Color(0xFF00E676),
                  ), // Green
                  const SizedBox(height: 16),
                  _buildInput(
                    "Extra Income",
                    _extraIncomeController,
                    _extraFocus,
                    const Color(0xFF00E676),
                  ), // Green
                  const SizedBox(height: 16),
                  _buildInput(
                    "EMI / Deductions",
                    _emiController,
                    _emiFocus,
                    const Color(0xFFFF5252),
                  ), // Red

                  const SizedBox(height: 32),
                  // --- Projected Splits Preview ---
                  if (_effectiveIncome > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PROJECTED ALLOCATIONS",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._config!.categories.map((cat) {
                          final amount =
                              _effectiveIncome * (cat.percentage / 100);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Percentage Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _accentColor.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        "${cat.percentage.toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          color: _accentColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat.name,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _currencyFormat.format(amount),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- STICKY BOTTOM BAR (Calculator) ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _bgColor,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Net Effective Income:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      _currencyFormat.format(_effectiveIncome),
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Save Budget",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- KEYBOARD ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _isKeyboardVisible
                ? CalculatorKeyboard(
                    onKeyPress: (v) => CalculatorKeyboard.handleKeyPress(
                      _activeController!,
                      v,
                    ),
                    onBackspace: () =>
                        CalculatorKeyboard.handleBackspace(_activeController!),
                    onClear: () => _activeController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(_activeController!),
                    onClose: _closeKeyboard,
                    onSwitchToSystem: _switchToSystemKeyboard,
                    onNext: _handleNext,
                    onPrevious:
                        _handlePrevious, // ADDED: Connected to previous logic
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _datePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl,
    FocusNode node,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          focusNode: node,
          readOnly: !_useSystemKeyboard,
          showCursor: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
            ),
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onTap: () => _setActive(ctrl, node),
        ),
      ],
    );
  }
}
