import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/financial_record_model.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/models/settlement_model.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../settings/services/settings_service.dart';
import '../services/settlement_service.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/design/budgetr_components.dart';

class SettlementInputSheet extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;
  final Map<String, double>? prefilledExpenses;

  const SettlementInputSheet({
    super.key,
    this.initialYear,
    this.initialMonth,
    this.prefilledExpenses,
  });

  @override
  State<SettlementInputSheet> createState() => _SettlementInputSheetState();
}

class _SettlementInputSheetState extends State<SettlementInputSheet> {
  final _settlementService = SettlementService();
  final _dashboardService = DashboardService();
  final _settingsService = SettingsService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final ScrollController _scrollController = ScrollController();

  List<Map<String, int>> _yearMonthData = [];
  List<int> _availableYears = [];
  List<int> _availableMonthsForYear = [];
  int? _selectedYear;
  int? _selectedMonth;

  FinancialRecord? _budgetRecord;
  Settlement? _existingSettlement;
  PercentageConfig? _percentageConfig;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  double _totalExpense = 0.0;
  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void initState() {
    super.initState();
    // If opened from Dashboard, set initial values immediately
    if (widget.initialYear != null && widget.initialMonth != null) {
      _selectedYear = widget.initialYear;
      _selectedMonth = widget.initialMonth;
    }
    _loadDropdownData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    _yearMonthData = await _settlementService.getAvailableMonthsForSettlement();
    final years = _yearMonthData.map((e) => e['year']!).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    _availableYears = years;
    _percentageConfig = await _settingsService.getPercentageConfig();

    // Setup Available Months logic
    if (_selectedYear != null) {
      // If year was pre-selected or defaults to now
      final months = _yearMonthData
          .where((data) => data['year'] == _selectedYear)
          .map((data) => data['month']!)
          .toSet()
          .toList();
      months.sort((a, b) => b.compareTo(a));
      _availableMonthsForYear = months;
    } else {
      // Default to current year logic if nothing passed
      final now = DateTime.now();
      if (_availableYears.contains(now.year)) {
        _selectedYear = now.year;
        final months = _yearMonthData
            .where((data) => data['year'] == now.year)
            .map((data) => data['month']!)
            .toSet()
            .toList();
        months.sort((a, b) => b.compareTo(a));
        _availableMonthsForYear = months;
        if (_availableMonthsForYear.contains(now.month)) {
          _selectedMonth = now.month;
        }
      }
    }

    // If we have both, fetch data immediately
    if (_selectedYear != null && _selectedMonth != null) {
      await _fetchData();
    }

    if (mounted) setState(() {});
  }

  void _onYearSelected(int? year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null;
      _budgetRecord = null;
      _controllers.clear();
      if (year != null) {
        final months = _yearMonthData
            .where((d) => d['year'] == year)
            .map((d) => d['month']!)
            .toSet()
            .toList();
        months.sort((a, b) => b.compareTo(a));
        _availableMonthsForYear = months;
      } else {
        _availableMonthsForYear = [];
      }
    });
  }

  Future<void> _fetchData() async {
    if (_selectedYear == null || _selectedMonth == null) return;
    final recordId =
        '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';

    try {
      final results = await Future.wait([
        _dashboardService.getRecordById(recordId),
        _settlementService.getSettlementById(recordId),
      ]);

      if (mounted) {
        setState(() {
          _budgetRecord = results[0] as FinancialRecord;
          _existingSettlement = results[1] as Settlement?;

          _controllers.clear();
          _focusNodes.clear();

          _budgetRecord!.allocations.forEach((key, _) {
            double initialValue = 0.0;

            // Priority 1: Existing Saved Settlement
            if (_existingSettlement != null &&
                _existingSettlement!.expenses.containsKey(key)) {
              initialValue = _existingSettlement!.expenses[key]!;
            }
            // Priority 2: Auto-filled from Dashboard (Pre-filled arguments)
            else if (widget.prefilledExpenses != null &&
                widget.prefilledExpenses!.containsKey(key)) {
              initialValue = widget.prefilledExpenses![key]!;
            }

            final ctrl = TextEditingController(
              text: initialValue == 0 ? '' : initialValue.toStringAsFixed(0),
            );
            ctrl.addListener(_calculateTotalExpense);
            _controllers[key] = ctrl;
            _focusNodes[key] = FocusNode();
          });

          _calculateTotalExpense();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching data: $e"),
            backgroundColor: BudgetrColors.error,
          ),
        );
      }
    }
  }

  void _calculateTotalExpense() {
    double sum = 0.0;
    for (var ctrl in _controllers.values) {
      sum += double.tryParse(ctrl.text) ?? 0.0;
    }
    setState(() => _totalExpense = sum);
  }

  // ... (Rest of keyboard logic: _scrollToInput, _setActive, etc. unchanged)
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

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _handleNext() {
    if (_activeController == null) return;
    final entries = _budgetRecord!.allocations.entries.toList();
    if (_percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = _percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    int currentIndex = -1;
    for (int i = 0; i < entries.length; i++) {
      if (_controllers[entries[i].key] == _activeController) {
        currentIndex = i;
        break;
      }
    }

    if (currentIndex != -1 && currentIndex < entries.length - 1) {
      final nextKey = entries[currentIndex + 1].key;
      _setActive(_controllers[nextKey]!, _focusNodes[nextKey]!);
    } else {
      _closeKeyboard();
    }
  }

  void _handlePrevious() {
    if (_activeController == null) return;
    final entries = _budgetRecord!.allocations.entries.toList();
    if (_percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = _percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    int currentIndex = -1;
    for (int i = 0; i < entries.length; i++) {
      if (_controllers[entries[i].key] == _activeController) {
        currentIndex = i;
        break;
      }
    }

    if (currentIndex > 0) {
      final prevKey = entries[currentIndex - 1].key;
      _setActive(_controllers[prevKey]!, _focusNodes[prevKey]!);
    } else {
      _closeKeyboard();
    }
  }

  Future<void> _onSettle() async {
    _closeKeyboard();
    if (_budgetRecord == null) return;

    Map<String, double> expenses = {};
    _controllers.forEach((key, ctrl) {
      expenses[key] = double.tryParse(ctrl.text) ?? 0.0;
    });

    final settlement = Settlement(
      id: _budgetRecord!.id,
      year: _budgetRecord!.year,
      month: _budgetRecord!.month,
      allocations: _budgetRecord!.allocations,
      expenses: expenses,
      totalIncome: _budgetRecord!.effectiveIncome,
      totalExpense: _totalExpense,
      settledAt: Timestamp.now(),
    );

    try {
      await _settlementService.saveSettlement(settlement);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Settlement saved successfully! Budget is now closed.',
            ),
            backgroundColor: BudgetrColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: BudgetrColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: BudgetrColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ModernDropdownPill<int>(
                          label: _selectedYear?.toString() ?? 'Year',
                          isActive: _selectedYear != null,
                          icon: Icons.calendar_today_outlined,
                          // Disable dropdown if launched in "Auto-fill mode"
                          isEnabled: widget.initialYear == null,
                          onTap: () => showSelectionSheet<int>(
                            context: context,
                            title: 'Select Year',
                            items: _availableYears,
                            labelBuilder: (y) => y.toString(),
                            onSelect: _onYearSelected,
                            selectedItem: _selectedYear,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernDropdownPill<int>(
                          label: _selectedMonth != null
                              ? DateFormat(
                                  'MMMM',
                                ).format(DateTime(0, _selectedMonth!))
                              : 'Month',
                          isActive: _selectedMonth != null,
                          icon: Icons.calendar_view_month_outlined,
                          isEnabled:
                              _selectedYear != null &&
                              widget.initialMonth == null,
                          onTap: () => showSelectionSheet<int>(
                            context: context,
                            title: 'Select Month',
                            items: _availableMonthsForYear,
                            labelBuilder: (m) =>
                                DateFormat('MMMM').format(DateTime(0, m)),
                            onSelect: (val) =>
                                setState(() => _selectedMonth = val),
                            selectedItem: _selectedMonth,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: BudgetrColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.downloading,
                            color: Colors.white70,
                          ),
                          onPressed: _fetchData,
                          tooltip: 'Fetch Budget Data',
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.white10),
                  Expanded(
                    child: _budgetRecord == null
                        ? Center(
                            child: Text(
                              'Select a month and fetch data to begin.',
                              style: BudgetrStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          )
                        : _buildSettlementForm(),
                  ),
                ],
              ),
            ),
          ),
          if (_budgetRecord != null) _buildStickyBottomBar(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
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
                    onPrevious: _handlePrevious,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ... (buildStickyBottomBar and buildSettlementForm from previous file remain same)
  Widget _buildStickyBottomBar() {
    final income = _budgetRecord!.effectiveIncome;
    final balance = income - _totalExpense;
    final isOverBudget = balance < 0;
    final progress = income > 0
        ? (_totalExpense / income).clamp(0.0, 1.0)
        : 0.0;
    final statusColor = isOverBudget
        ? BudgetrColors.error
        : BudgetrColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BudgetrColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
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
              Text(
                "Total Spent: ${_currencyFormat.format(_totalExpense)}",
                style: BudgetrStyles.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isOverBudget
                    ? "Over by ${_currencyFormat.format(balance.abs())}"
                    : "Left: ${_currencyFormat.format(balance)}",
                style: BudgetrStyles.body.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BudgetrStyles.radiusM,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _onSettle,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: BudgetrColors.primaryGradient,
                      borderRadius: BudgetrStyles.radiusM,
                      boxShadow: BudgetrStyles.glowBoxShadow(
                        BudgetrColors.accent,
                      ),
                    ),
                    child: const Text(
                      'Settle Budget',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementForm() {
    final entries = _budgetRecord!.allocations.entries.toList();
    if (_percentageConfig != null) {
      entries.sort((a, b) {
        int idxA = _percentageConfig!.categories.indexWhere(
          (c) => c.name == a.key,
        );
        int idxB = _percentageConfig!.categories.indexWhere(
          (c) => c.name == b.key,
        );
        if (idxA == -1) idxA = 999;
        if (idxB == -1) idxB = 999;
        return idxA.compareTo(idxB);
      });
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }

    return GestureDetector(
      onTap: _closeKeyboard,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildSettlementRow(
            title: entry.key,
            allocated: entry.value,
            controller: _controllers[entry.key]!,
          );
        },
      ),
    );
  }

  Widget _buildSettlementRow({
    required String title,
    required double allocated,
    required TextEditingController controller,
  }) {
    if (!_focusNodes.containsKey(title)) _focusNodes[title] = FocusNode();
    final focusNode = _focusNodes[title]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: BudgetrStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Allocated: ${_currencyFormat.format(allocated)}',
          style: BudgetrStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        trailing: SizedBox(
          width: 140,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: !_useSystemKeyboard,
            showCursor: true,
            textAlign: TextAlign.end,
            keyboardType: TextInputType.number,
            style: BudgetrStyles.h3.copyWith(fontWeight: FontWeight.bold),
            cursorColor: BudgetrColors.accent,
            decoration: InputDecoration(
              isDense: true,
              hintText: '0',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BudgetrStyles.radiusS,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BudgetrStyles.radiusS,
                borderSide: const BorderSide(color: BudgetrColors.accent),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onTap: () => _setActive(controller, focusNode),
          ),
        ),
      ),
    );
  }
}
