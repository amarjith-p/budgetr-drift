import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/features/investments/services/passive_income_service.dart';
// [NEW IMPORT]
import 'package:budget/features/investments/widgets/compact_calculator_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart'; // [NEW IMPORT]

class PassiveIncomeSheet extends StatefulWidget {
  final int investmentId;

  const PassiveIncomeSheet({
    super.key,
    required this.investmentId,
  });

  @override
  State<PassiveIncomeSheet> createState() => _PassiveIncomeSheetState();
}

class _PassiveIncomeSheetState extends State<PassiveIncomeSheet> {
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'dividend'; // or 'interest'
  bool _isLoading = false;

  // --- NEW: Evaluate Math ---
  double? _evaluateFinalAmount() {
    try {
      String expression =
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LOG PASSIVE INCOME",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildToggle('Dividend', 'dividend'),
                    _buildToggle('Interest', 'interest'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          const Text("Amount Received",
              style: TextStyle(color: Colors.white70, fontSize: 13)),

          // --- UPDATED TEXT FIELD ---
          TextField(
            controller: _amountController,
            readOnly: true, // Prevents system keyboard
            showCursor: true, // Keeps cursor active
            autofocus: false,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle:
                  TextStyle(color: Colors.amber.withOpacity(0.5), fontSize: 36),
              hintText: "0.00",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
              border: InputBorder.none,
            ),
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text("Change",
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- NEW CUSTOM KEYBOARD ---
          CompactCalculatorKeyboard(controller: _amountController),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const FuturisticLoader(size: 20, color: Colors.black)
                  : const Text(
                      "ADD INCOME",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, String value) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.amber.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amber : Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.amber,
            surface: Color(0xFF1B263B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final amount = _evaluateFinalAmount();
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid mathematical expression")));
      return;
    }
    if (amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      await PassiveIncomeService().logIncome(
        investmentId: widget.investmentId,
        amount: amount,
        date: _selectedDate,
        type: _type,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
