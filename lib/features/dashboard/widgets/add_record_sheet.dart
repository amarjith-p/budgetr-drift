import 'package:budget/features/dashboard/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../../core/models/financial_record_model.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/services/firestore_service.dart';

class AddRecordSheet extends StatefulWidget {
  final FinancialRecord? recordToEdit;

  const AddRecordSheet({super.key, this.recordToEdit});

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _salaryController;
  late TextEditingController _extraIncomeController;
  late TextEditingController _emiController;

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
  bool _isKeyboardVisible = false;
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

      _firestoreService.getPercentageConfig().then((config) {
        setState(() {
          _config = config;
        });
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

  Future<void> _onRecordPressed() async {
    setState(() {
      _isKeyboardVisible = false;
    });
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
        await _firestoreService.setFinancialRecord(record);
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

  // Keyboard Handlers
  void _handleKeyPress(String value) {
    if (_activeController == null) return;
    final controller = _activeController!;
    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, value);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  void _handleBackspace() {
    if (_activeController == null) return;
    final controller = _activeController!;
    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    if (start > 0) {
      final newText = text.replaceRange(start - 1, start, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start - 1),
      );
    }
  }

  void _handleClear() {
    _activeController?.clear();
  }

  void _handleEquals() {
    if (_activeController == null || _activeController!.text.isEmpty) return;
    String expression = _activeController!.text
        .replaceAll('×', '*')
        .replaceAll('÷', '/');
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      _activeController!.text = result.toStringAsFixed(2);
      _activeController!.selection = TextSelection.fromPosition(
        TextPosition(offset: _activeController!.text.length),
      );
    } catch (e) {
      /* Ignore */
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
                onTap: () => setState(() => _isKeyboardVisible = false),
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
                        labelText: 'Salary*',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildCalcFormField(
                        controller: _extraIncomeController,
                        labelText: 'Extra Income',
                      ),
                      const SizedBox(height: 16),
                      _buildCalcFormField(
                        controller: _emiController,
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

                      // --- MODERN DROPDOWNS ---
                      Row(
                        children: [
                          Expanded(
                            child: ModernDropdownPill<int>(
                              label: _selectedYear?.toString() ?? 'Year',
                              isActive: _selectedYear != null,
                              icon: Icons.calendar_today_outlined,
                              isEnabled: !_isEditing, // Disable if editing
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
                              isEnabled: !_isEditing, // Disable if editing
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

                      // -----------------------
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
                ? _CalculatorKeyboard(
                    onKeyPress: _handleKeyPress,
                    onBackspace: _handleBackspace,
                    onClear: _handleClear,
                    onEquals: _handleEquals,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      showCursor: true,
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
      onTap: () {
        setState(() {
          _isKeyboardVisible = true;
          _activeController = controller;
        });
      },
    );
  }

  Widget _buildCalculationsDisplay() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final sortedEntries = _calculatedValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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

class _CalculatorKeyboard extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onEquals;

  const _CalculatorKeyboard({
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    required this.onEquals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _k('('),
              _k(')'),
              _k('C', a: onClear, f: true),
              _k('⌫', a: onBackspace, f: true, i: Icons.backspace_outlined),
            ],
          ),
          Row(
            children: [
              _k('7'),
              _k('8'),
              _k('9'),
              _k('÷', a: () => onKeyPress('/'), f: true),
            ],
          ),
          Row(
            children: [
              _k('4'),
              _k('5'),
              _k('6'),
              _k('×', a: () => onKeyPress('*'), f: true),
            ],
          ),
          Row(children: [_k('1'), _k('2'), _k('3'), _k('-', f: true)]),
          Row(
            children: [
              _k('.'),
              _k('0'),
              _k('=', a: onEquals, f: true, e: true),
              _k('+', f: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _k(
    String t, {
    VoidCallback? a,
    bool f = false,
    bool e = false,
    IconData? i,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: e
            ? FilledButton(
                onPressed: a,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: () => a != null ? a() : onKeyPress(t),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: f
                      ? Colors.cyanAccent.shade400
                      : Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                child: i != null
                    ? Icon(i, size: 20)
                    : Text(
                        t,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
      ),
    );
  }
}
