import 'package:flutter/material.dart';
import '../../../../core/models/custom_data_models.dart';

class FormulaInputBlock extends StatefulWidget {
  final CustomFieldConfig field;
  final List<CustomFieldConfig> allFields;
  final Color accentColor;

  const FormulaInputBlock({
    super.key,
    required this.field,
    required this.allFields,
    required this.accentColor,
  });

  @override
  State<FormulaInputBlock> createState() => _FormulaInputBlockState();
}

class _FormulaInputBlockState extends State<FormulaInputBlock> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.formulaExpression);
    _controller.addListener(() {
      widget.field.formulaExpression = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addToken(String token) {
    final text = _controller.text;
    String newText;

    bool isDigit = RegExp(r'[0-9.]').hasMatch(token);
    bool lastWasDigit = text.isNotEmpty && RegExp(r'[0-9.]$').hasMatch(text);
    bool isOp = ['+', '-', '*', '/'].contains(token);

    if (isDigit && lastWasDigit) {
      newText = text + token;
    } else if (isOp) {
      newText = text.trimRight() + ' $token ';
    } else {
      if (text.isNotEmpty && !text.endsWith(' '))
        newText = text + ' ' + token;
      else
        newText = text + token;
    }

    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void _backspace() {
    final text = _controller.text;
    if (text.isEmpty) return;
    _controller.text = text.substring(0, text.length - 1);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void _clear() => _controller.clear();

  @override
  Widget build(BuildContext context) {
    final availableFields = widget.allFields
        .where(
          (f) =>
              f != widget.field &&
              f.name.isNotEmpty &&
              (f.type == CustomFieldType.number ||
                  f.type == CustomFieldType.currency),
        )
        .map((f) => f.name)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.accentColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Visual Formula Builder",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              readOnly: true,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Tap below to build formula',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.backspace, size: 18),
                  color: Colors.white54,
                  onPressed: _backspace,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (availableFields.isNotEmpty) ...[
              const Text(
                "Fields:",
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableFields.map((fname) {
                  return InkWell(
                    onTap: () => _addToken('[$fname]'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        fname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              "Operators:",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildOpBtn('+'),
                _buildOpBtn('-'),
                _buildOpBtn('*'),
                _buildOpBtn('/'),
                _buildOpBtn('('),
                _buildOpBtn(')'),
                _buildActionBtn('CLR', Colors.redAccent, _clear),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Numbers:",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildBtn('1'),
                _buildBtn('2'),
                _buildBtn('3'),
                _buildBtn('4'),
                _buildBtn('5'),
                _buildBtn('6'),
                _buildBtn('7'),
                _buildBtn('8'),
                _buildBtn('9'),
                _buildBtn('0'),
                _buildBtn('.'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: widget.field.isSumRequired,
                  activeColor: widget.accentColor,
                  onChanged: (val) =>
                      setState(() => widget.field.isSumRequired = val!),
                ),
                const Text(
                  'Calculate Total',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(String label) {
    return InkWell(
      onTap: () => _addToken(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOpBtn(String label) {
    return InkWell(
      onTap: () => _addToken(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.accentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
