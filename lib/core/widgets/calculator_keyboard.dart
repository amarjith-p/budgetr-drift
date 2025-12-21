import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorKeyboard extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onEquals;
  final VoidCallback? onClose;
  final VoidCallback? onSwitchToSystem;
  final VoidCallback? onNext; // NEW: Callback for Next button

  const CalculatorKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    required this.onEquals,
    this.onClose,
    this.onSwitchToSystem,
    this.onNext,
  });

  // Static helpers (Unchanged)
  static void handleKeyPress(TextEditingController ctrl, String value) {
    final text = ctrl.text;
    final selection = ctrl.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, value);
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  static void handleBackspace(TextEditingController ctrl) {
    final text = ctrl.text;
    final selection = ctrl.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    if (start > 0) {
      final newText = text.replaceRange(start - 1, start, '');
      ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start - 1),
      );
    }
  }

  static void handleEquals(TextEditingController ctrl) {
    String expression = ctrl.text.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      ctrl.text = result.toStringAsFixed(2);
      ctrl.selection = TextSelection.fromPosition(
        TextPosition(offset: ctrl.text.length),
      );
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Control Row
          SizedBox(
            height: 48,
            child: Row(
              children: [
                if (onSwitchToSystem != null)
                  TextButton.icon(
                    icon: const Icon(Icons.keyboard_outlined, size: 20),
                    label: const Text("System Keyboard"),
                    onPressed: onSwitchToSystem,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                const Spacer(),
                // NEW: Next Button
                if (onNext != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    onPressed: onNext,
                    tooltip: 'Next Field',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.keyboard_hide_outlined),
                  onPressed: onClose,
                  tooltip: 'Close',
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 4),
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
