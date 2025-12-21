import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/financial_record_model.dart';
import '../../../core/models/percentage_config_model.dart';
import '../services/dashboard_service.dart';
import '../../settings/services/settings_service.dart';

class AddRecordSheet extends StatefulWidget {
  final FinancialRecord? recordToEdit;

  const AddRecordSheet({super.key, this.recordToEdit});

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dashboardService = DashboardService();
  final _settingsService = SettingsService();

  late TextEditingController _salaryController;
  late TextEditingController _extraIncomeController;
  late TextEditingController _emiController;

  // Focus Nodes for Cursor Management
  final FocusNode _salaryFocus = FocusNode();
  final FocusNode _extraFocus = FocusNode();
  final FocusNode _emiFocus = FocusNode();

  int? _selectedYear;
  int? _selectedMonth;
  final List<int> _years = List.generate(
    50,
    (index) => DateTime.now().year - 5 + index,
  );
  final List<int> _months = List.generate(12, (index) => index + 1);

  double _effectiveIncome = 0;
  Map<String, double> _calculatedValues = {};
  PercentageConfig? _config;

  TextEditingController? _activeController;
  FocusNode? _activeFocusNode;

  bool _isKeyboardVisible = false;
  bool _isEditing = false;
  bool _useSystemKeyboard = false;

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

    if (_isEditing) {
      _selectedYear = widget.recordToEdit!.year;
      _selectedMonth = widget.recordToEdit!.month;

      List<CategoryConfig> historicalCats = [];
      widget.recordToEdit!.allocationPercentages.forEach((key, value) {
        historicalCats.add(CategoryConfig(name: key, percentage: value));
      });
      _config = PercentageConfig(categories: historicalCats);
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
    } else {
      final now = DateTime.now();
      _selectedYear = now.year;
      _selectedMonth = now.month;

      _settingsService.getPercentageConfig().then((config) {
        setState(() => _config = config);
      });
    }

    _salaryController.addListener(_calculate);
    _extraIncomeController.addListener(_calculate);
    _emiController.addListener(_calculate);
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _extraIncomeController.dispose();
    _emiController.dispose();
    _salaryFocus.dispose();
    _extraFocus.dispose();
    _emiFocus.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_config == null) return;
    final salary = double.tryParse(_salaryController.text) ?? 0;
    final extraIncome = double.tryParse(_extraIncomeController.text) ?? 0;
    final emi = double.tryParse(_emiController.text) ?? 0;

    setState(() {
      _effectiveIncome = (salary + extraIncome) - emi;
      if (_effectiveIncome < 0) _effectiveIncome = 0;

      _calculatedValues.clear();
      for (var category in _config!.categories) {
        _calculatedValues[category.name] =
            _effectiveIncome * (category.percentage / 100.0);
      }
    });
  }

  // --- Keyboard Logic ---
  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeController = ctrl;
      _activeFocusNode = node;

      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
  }

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    if (_activeFocusNode != null) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).requestFocus(_activeFocusNode);
      });
    }
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  // NEW: Logic to jump to the next field
  void _handleNext() {
    if (_activeFocusNode == _salaryFocus) {
      _setActive(_extraIncomeController, _extraFocus);
    } else if (_activeFocusNode == _extraFocus) {
      _setActive(_emiController, _emiFocus);
    } else {
      _closeKeyboard(); // Close if we are at the last field
    }
  }

  Future<void> _onRecordPressed() async {
    _closeKeyboard();
    await Future.delayed(const Duration(milliseconds: 100));

    if (_formKey.currentState!.validate()) {
      if (_config == null) return;

      final idString =
          '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';

      Map<String, double> allocations = {};
      Map<String, double> percentages = {};

      for (var category in _config!.categories) {
        allocations[category.name] = _calculatedValues[category.name] ?? 0.0;
        percentages[category.name] = category.percentage;
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
        createdAt: widget.recordToEdit?.createdAt ?? Timestamp.now(),
      );

      try {
        await _dashboardService.setFinancialRecord(record);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing ? 'Record updated!' : 'Record saved successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null) {
      return const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: GestureDetector(
                onTap: _closeKeyboard,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit Record' : 'New Monthly Record',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      _buildCalcFormField(
                        controller: _salaryController,
                        focusNode: _salaryFocus,
                        labelText: 'Salary*',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildCalcFormField(
                        controller: _extraIncomeController,
                        focusNode: _extraFocus,
                        labelText: 'Extra Income',
                      ),
                      const SizedBox(height: 16),
                      _buildCalcFormField(
                        controller: _emiController,
                        focusNode: _emiFocus,
                        labelText: 'EMI',
                      ),
                      const SizedBox(height: 24),
                      if (_effectiveIncome > 0) _buildCalculationsDisplay(),
                      const SizedBox(height: 24),
                      Text(
                        'Record for Month & Year',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ModernDropdownPill<int>(
                              label: _selectedYear?.toString() ?? 'Year',
                              isActive: _selectedYear != null,
                              icon: Icons.calendar_today_outlined,
                              isEnabled: !_isEditing,
                              onTap: () => showSelectionSheet<int>(
                                context: context,
                                title: 'Select Year',
                                items: _years,
                                labelBuilder: (y) => y.toString(),
                                onSelect: (val) =>
                                    setState(() => _selectedYear = val),
                                selectedItem: _selectedYear,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ModernDropdownPill<int>(
                              label: _selectedMonth != null
                                  ? DateFormat(
                                      'MMMM',
                                    ).format(DateTime(0, _selectedMonth!))
                                  : 'Month',
                              isActive: _selectedMonth != null,
                              icon: Icons.calendar_view_month_outlined,
                              isEnabled: !_isEditing,
                              onTap: () => showSelectionSheet<int>(
                                context: context,
                                title: 'Select Month',
                                items: _months,
                                labelBuilder: (m) =>
                                    DateFormat('MMMM').format(DateTime(0, m)),
                                onSelect: (val) =>
                                    setState(() => _selectedMonth = val),
                                selectedItem: _selectedMonth,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _onRecordPressed,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Text(_isEditing ? 'Update Record' : 'Record'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                    onClose: _closeKeyboard, // WIRED
                    onSwitchToSystem: _switchToSystemKeyboard, // WIRED
                    onNext: _handleNext, // WIRED
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: !_useSystemKeyboard, // Uses the state variable
      showCursor: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
      onTap: () => _setActive(controller, focusNode),
    );
  }

  Widget _buildCalculationsDisplay() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    List<MapEntry<String, double>> sortedEntries = [];
    if (_config != null) {
      for (var cat in _config!.categories) {
        if (_calculatedValues.containsKey(cat.name)) {
          sortedEntries.add(MapEntry(cat.name, _calculatedValues[cat.name]!));
        }
      }
      for (var entry in _calculatedValues.entries) {
        if (!sortedEntries.any((e) => e.key == entry.key)) {
          sortedEntries.add(entry);
        }
      }
    } else {
      sortedEntries = _calculatedValues.entries.toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Effective Income: ${currencyFormat.format(_effectiveIncome)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...sortedEntries.map((entry) {
            final percent = _config!.categories
                .firstWhere(
                  (c) => c.name == entry.key,
                  orElse: () => CategoryConfig(name: '', percentage: 0),
                )
                .percentage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${entry.key} (${percent.toStringAsFixed(0)}%)'),
                  Text(
                    currencyFormat.format(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
