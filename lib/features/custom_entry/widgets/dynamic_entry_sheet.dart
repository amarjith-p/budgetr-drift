import 'package:budget/features/dashboard/widgets/calculator_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';

class DynamicEntrySheet extends StatefulWidget {
  final CustomTemplate template;
  const DynamicEntrySheet({super.key, required this.template});

  @override
  State<DynamicEntrySheet> createState() => _DynamicEntrySheetState();
}

class _DynamicEntrySheetState extends State<DynamicEntrySheet> {
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController? _activeCalcController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    for (var field in widget.template.fields) {
      if (field.type != CustomFieldType.date) {
        _controllers[field.name] = TextEditingController();
      } else {
        _formData[field.name] = DateTime.now();
      }
    }
  }

  Future<void> _save() async {
    for (var field in widget.template.fields) {
      if (field.type == CustomFieldType.number) {
        _formData[field.name] =
            double.tryParse(_controllers[field.name]!.text) ?? 0.0;
      } else if (field.type == CustomFieldType.string) {
        _formData[field.name] = _controllers[field.name]!.text;
      }
    }

    final record = CustomRecord(
      id: '',
      templateId: widget.template.id,
      data: _formData,
      createdAt: DateTime.now(),
    );

    await FirestoreService().addCustomRecord(record);
    if (mounted) Navigator.pop(context);
  }

  void _reset() {
    _controllers.values.forEach((c) => c.clear());
    setState(() {
      for (var field in widget.template.fields) {
        if (field.type == CustomFieldType.date)
          _formData[field.name] = DateTime.now();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.template.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: widget.template.fields
                  .map((field) => _buildFieldInput(field))
                  .toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Record Entry'),
                  ),
                ),
              ],
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _isKeyboardVisible
                ? CalculatorKeyboard(
                    onKeyPress: (v) => CalculatorKeyboard.handleKeyPress(
                      _activeCalcController!,
                      v,
                    ),
                    onBackspace: () => CalculatorKeyboard.handleBackspace(
                      _activeCalcController!,
                    ),
                    onClear: () => _activeCalcController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(_activeCalcController!),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(CustomFieldConfig field) {
    if (field.type == CustomFieldType.date) {
      final val = _formData[field.name] as DateTime;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: val,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _formData[field.name] = picked);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 12),
                Text(DateFormat('dd MMM yyyy').format(val)),
                const Spacer(),
                Text(
                  field.name,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isNum = field.type == CustomFieldType.number;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[field.name],
        readOnly: isNum,
        onTap: isNum
            ? () {
                setState(() {
                  _activeCalcController = _controllers[field.name];
                  _isKeyboardVisible = true;
                });
              }
            : () => setState(() => _isKeyboardVisible = false),
        decoration: InputDecoration(
          labelText: field.name,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(isNum ? Icons.onetwothree : Icons.text_fields),
        ),
      ),
    );
  }
}
