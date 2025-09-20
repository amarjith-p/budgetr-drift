import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../../core/models/financial_record_model.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../../core/services/firestore_service.dart';

class AddRecordSheet extends StatefulWidget {
  const AddRecordSheet({super.key});

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _salaryController = TextEditingController();
  final _extraIncomeController = TextEditingController();
  final _emiController = TextEditingController();

  int? _selectedYear;
  int? _selectedMonth;
  final List<int> _years = List.generate(
    10,
    (index) => DateTime.now().year - 5 + index,
  );
  final List<int> _months = List.generate(12, (index) => index + 1);

  double _effectiveIncome = 0;
  Map<String, double> _calculatedValues = {};
  PercentageConfig? _config;

  // --- NEW: State for custom keyboard ---
  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;

    _firestoreService.getPercentageConfig().then((config) {
      setState(() {
        _config = config;
      });
    });

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
      _calculatedValues = {
        'Necessities (${_config!.necessities.toStringAsFixed(0)}%)':
            _effectiveIncome * (_config!.necessities / 100.0),
        'Lifestyle (${_config!.lifestyle.toStringAsFixed(0)}%)':
            _effectiveIncome * (_config!.lifestyle / 100.0),
        'Investment (${_config!.investment.toStringAsFixed(0)}%)':
            _effectiveIncome * (_config!.investment / 100.0),
        'Emergency (${_config!.emergency.toStringAsFixed(0)}%)':
            _effectiveIncome * (_config!.emergency / 100.0),
        'Buffer (${_config!.buffer.toStringAsFixed(0)}%)':
            _effectiveIncome * (_config!.buffer / 100.0),
      };
    });
  }

  Future<void> _onRecordPressed() async {
    setState(() {
      _isKeyboardVisible = false;
    });
    await Future.delayed(const Duration(milliseconds: 100));

    if (_formKey.currentState!.validate()) {
      if (_config == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Percentage settings are still loading."),
          ),
        );
        return;
      }

      final idString =
          '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';

      final record = FinancialRecord(
        id: idString,
        salary: double.tryParse(_salaryController.text) ?? 0,
        extraIncome: double.tryParse(_extraIncomeController.text) ?? 0,
        emi: double.tryParse(_emiController.text) ?? 0,
        year: _selectedYear!,
        month: _selectedMonth!,
        effectiveIncome: _effectiveIncome,
        necessities:
            _calculatedValues['Necessities (${_config!.necessities.toStringAsFixed(0)}%)']!,
        lifestyle:
            _calculatedValues['Lifestyle (${_config!.lifestyle.toStringAsFixed(0)}%)']!,
        investment:
            _calculatedValues['Investment (${_config!.investment.toStringAsFixed(0)}%)']!,
        emergency:
            _calculatedValues['Emergency (${_config!.emergency.toStringAsFixed(0)}%)']!,
        buffer:
            _calculatedValues['Buffer (${_config!.buffer.toStringAsFixed(0)}%)']!,
        createdAt: Timestamp.now(),
        necessitiesPercentage: _config!.necessities,
        lifestylePercentage: _config!.lifestyle,
        investmentPercentage: _config!.investment,
        emergencyPercentage: _config!.emergency,
        bufferPercentage: _config!.buffer,
      );

      try {
        await _firestoreService.setFinancialRecord(record);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving record: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleKeyPress(String value) {
    if (_activeController == null) return;
    final controller = _activeController!;
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, value);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + value.length,
      ),
    );
  }

  void _handleBackspace() {
    if (_activeController == null) return;
    final controller = _activeController!;
    final text = controller.text;
    final selection = controller.selection;
    if (selection.baseOffset > 0) {
      final newText = text.replaceRange(
        selection.start - 1,
        selection.start,
        '',
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    }
  }

  void _handleClear() {
    if (_activeController == null) return;
    _activeController!.clear();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Expression'),
          backgroundColor: Colors.red,
        ),
      );
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
                        'New Monthly Record',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      _buildCalcFormField(
                        controller: _salaryController,
                        labelText: 'Salary*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Salary is mandatory';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number/expression';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildYearDropdown()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMonthDropdown()),
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
                          child: const Text('Record'),
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

  InputDecoration _modernDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: _modernDropdownDecoration('Year'),
      items: _years
          .map(
            (year) =>
                DropdownMenuItem(value: year, child: Text(year.toString())),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedYear = value),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      decoration: _modernDropdownDecoration('Month'),
      items: _months
          .map(
            (month) => DropdownMenuItem(
              value: month,
              child: Text(DateFormat('MMMM').format(DateTime(0, month))),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedMonth = value),
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
          ..._calculatedValues.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    currencyFormat.format(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
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
              _buildKey('('),
              _buildKey(')'),
              _buildKey('C', onAction: onClear, isFunction: true),
              _buildKey(
                '⌫',
                onAction: onBackspace,
                isFunction: true,
                icon: Icons.backspace_outlined,
              ),
            ],
          ),
          Row(
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
              _buildKey('÷', onAction: () => onKeyPress('/'), isFunction: true),
            ],
          ),
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
              _buildKey('×', onAction: () => onKeyPress('*'), isFunction: true),
            ],
          ),
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildKey('-', isFunction: true),
            ],
          ),
          Row(
            children: [
              _buildKey('.'),
              _buildKey('0'),
              _buildKey(
                '=',
                onAction: onEquals,
                isFunction: true,
                isEquals: true,
              ),
              _buildKey('+', isFunction: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    String text, {
    VoidCallback? onAction,
    bool isFunction = false,
    bool isEquals = false,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: isEquals
            ? FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: () =>
                    onAction != null ? onAction() : onKeyPress(text),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: isFunction
                      ? Colors.cyanAccent.shade400
                      : Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                child: icon != null
                    ? Icon(icon, size: 20)
                    : Text(
                        text,
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
