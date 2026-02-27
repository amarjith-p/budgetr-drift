import 'package:budget/core/design/budgetr_colors.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CompactCalculatorKeyboard extends StatelessWidget {
  final TextEditingController controller;

  const CompactCalculatorKeyboard({super.key, required this.controller});

  void _onKeyPress(String value) {
    final text = controller.text;
    final selection = controller.selection;

    int start = selection.baseOffset;
    int end = selection.extentOffset;

    // Default to end of string if selection is missing
    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    if (value == 'C') {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);
    } else if (value == '⌫') {
      if (start > 0 && start == end) {
        final newText = text.substring(0, start - 1) + text.substring(end);
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start - 1),
        );
      } else if (start != end) {
        final newText = text.substring(0, start) + text.substring(end);
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
      }
    } else if (value == '=') {
      _evaluate();
    } else {
      final newText = text.substring(0, start) + value + text.substring(end);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + value.length),
      );
    }
  }

  void _evaluate() {
    if (controller.text.isEmpty) return;
    try {
      // Replace display operators with math operators
      String expression =
          controller.text.replaceAll('×', '*').replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Clean up trailing decimals
      String result = eval.toStringAsFixed(2);
      if (result.endsWith('.00')) {
        result = result.substring(0, result.length - 3);
      } else if (result.endsWith('0')) {
        result = result.substring(0, result.length - 1);
      }

      controller.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    } catch (e) {
      // If expression is incomplete (e.g. "50+"), do nothing on '=' press
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['C', '(', ')', '⌫'],
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['.', '0', '=', '+'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: row.map((label) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildKey(label),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String label) {
    bool isOperator = ['÷', '×', '-', '+'].contains(label);
    bool isAction = ['C', '⌫', '(', ')'].contains(label);
    bool isEqual = label == '=';

    Color bgColor = Colors.white.withOpacity(0.05);
    Color textColor = Colors.white;

    if (isOperator) {
      bgColor = BudgetrColors.accent.withOpacity(0.15);
      textColor = BudgetrColors.accent;
    } else if (isAction) {
      bgColor = Colors.redAccent.withOpacity(0.15);
      textColor = Colors.redAccent;
      if (label == '(' || label == ')') {
        bgColor = Colors.white.withOpacity(0.1);
        textColor = Colors.white70;
      }
    } else if (isEqual) {
      bgColor = BudgetrColors.success;
      textColor = Colors.black;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48, // Compact height
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
