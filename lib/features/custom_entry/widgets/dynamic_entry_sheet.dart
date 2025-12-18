import 'package:budget/features/dashboard/widgets/calculator_keyboard.dart';
import 'package:budget/features/dashboard/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';

class DynamicEntrySheet extends StatefulWidget {
  final CustomTemplate template;
  final CustomRecord? recordToEdit;

  const DynamicEntrySheet({
    super.key,
    required this.template,
    this.recordToEdit,
  });

  @override
  State<DynamicEntrySheet> createState() => _DynamicEntrySheetState();
}

class _DynamicEntrySheetState extends State<DynamicEntrySheet> {
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController? _activeCalcController;
  bool _isKeyboardVisible = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.recordToEdit != null;

    for (var field in widget.template.fields) {
      dynamic initialVal;
      if (_isEditing && widget.recordToEdit!.data.containsKey(field.name)) {
        initialVal = widget.recordToEdit!.data[field.name];
      }

      // Initialize data containers
      if (field.type == CustomFieldType.date) {
        if (initialVal is Timestamp)
          _formData[field.name] = initialVal.toDate();
        else if (initialVal is DateTime)
          _formData[field.name] = initialVal;
        else
          _formData[field.name] = DateTime.now();
      } else if (field.type == CustomFieldType.dropdown) {
        _formData[field.name] = initialVal; // String or null
      } else {
        // String, Number, Currency
        _controllers[field.name] = TextEditingController(
          text: initialVal?.toString() ?? '',
        );
      }
    }
  }

  Future<void> _save() async {
    for (var field in widget.template.fields) {
      if (field.type == CustomFieldType.number ||
          field.type == CustomFieldType.currency) {
        _formData[field.name] =
            double.tryParse(_controllers[field.name]!.text) ?? 0.0;
      } else if (field.type == CustomFieldType.string) {
        _formData[field.name] = _controllers[field.name]!.text;
      }
      // Date and Dropdown are already in _formData
    }

    final record = CustomRecord(
      id: widget.recordToEdit?.id ?? '',
      templateId: widget.template.id,
      data: _formData,
      createdAt: widget.recordToEdit?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await FirestoreService().updateCustomRecord(record);
    } else {
      await FirestoreService().addCustomRecord(record);
    }

    if (mounted) Navigator.pop(context);
  }

  void _reset() {
    _controllers.values.forEach((c) => c.clear());
    setState(() {
      _formData.clear();
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
                  _isEditing ? 'Edit Entry' : widget.template.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (!_isEditing)
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
                    child: Text(_isEditing ? 'Update' : 'Record Entry'),
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
    // 1. DATE
    if (field.type == CustomFieldType.date) {
      final val = _formData[field.name] as DateTime;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: val,
              firstDate: DateTime(1900),
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

    // 2. DROPDOWN
    if (field.type == CustomFieldType.dropdown) {
      final val = _formData[field.name];
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ModernDropdownPill<String>(
          label: val ?? 'Select ${field.name}',
          isActive: val != null,
          icon: Icons.arrow_drop_down_circle_outlined,
          onTap: () => showSelectionSheet<String>(
            context: context,
            title: 'Select ${field.name}',
            items: field.dropdownOptions ?? [],
            labelBuilder: (s) => s,
            onSelect: (v) => setState(() => _formData[field.name] = v),
            selectedItem: val,
          ),
        ),
      );
    }

    // 3. TEXT / NUMBER / CURRENCY
    final isNum =
        field.type == CustomFieldType.number ||
        field.type == CustomFieldType.currency;
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
          // Add Symbol for Currency
          prefixText: field.type == CustomFieldType.currency
              ? '${field.currencySymbol} '
              : null,
          prefixIcon: Icon(isNum ? Icons.onetwothree : Icons.text_fields),
        ),
      ),
    );
  }
}
