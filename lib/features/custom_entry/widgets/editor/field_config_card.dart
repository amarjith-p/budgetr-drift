import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_dropdown.dart';
import '../../../../core/models/custom_data_models.dart';
import 'dropdown_input_block.dart';
import 'formula_input_block.dart';

class FieldConfigCard extends StatefulWidget {
  final int index;
  final CustomFieldConfig field;
  final List<CustomFieldConfig> allFields;
  final VoidCallback onRemove;
  final Color cardColor;
  final Color accentColor;
  final Color bgColor;

  const FieldConfigCard({
    super.key,
    required this.index,
    required this.field,
    required this.allFields,
    required this.onRemove,
    required this.cardColor,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  State<FieldConfigCard> createState() => _FieldConfigCardState();
}

class _FieldConfigCardState extends State<FieldConfigCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator, color: Colors.white24),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: widget.field.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Field Name (e.g. Price)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => widget.field.name = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          Row(
            children: [
              Expanded(
                child: ModernDropdownPill<CustomFieldType>(
                  label: _getTypeLabel(widget.field.type),
                  isActive: true,
                  icon: _getTypeIcon(widget.field.type),
                  onTap: () => showSelectionSheet<CustomFieldType>(
                    context: context,
                    title: 'Field Type',
                    items: CustomFieldType.values,
                    labelBuilder: (t) => _getTypeLabel(t),
                    onSelect: (val) {
                      setState(() => widget.field.type = val!);
                    },
                    selectedItem: widget.field.type,
                  ),
                ),
              ),
            ],
          ),
          if (widget.field.type == CustomFieldType.number ||
              widget.field.type == CustomFieldType.currency)
            _buildNumberConfig(),
          if (widget.field.type == CustomFieldType.dropdown)
            DropdownInputBlock(
              field: widget.field,
              accentColor: widget.accentColor,
            ),
          if (widget.field.type == CustomFieldType.serial) _buildSerialConfig(),
          if (widget.field.type == CustomFieldType.formula)
            FormulaInputBlock(
              field: widget.field,
              allFields: widget.allFields,
              accentColor: widget.accentColor,
            ),
        ],
      ),
    );
  }

  Widget _buildNumberConfig() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
            if (widget.field.type == CustomFieldType.currency) ...[
              const Spacer(),
              DropdownButton<String>(
                value: widget.field.currencySymbol ?? '₹',
                dropdownColor: widget.bgColor,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: ['₹', '\$', '€', '£']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => widget.field.currencySymbol = val),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSerialConfig() {
    bool hasConfig =
        widget.field.serialPrefix != null || widget.field.serialSuffix != null;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Custom Format",
                  style: TextStyle(color: Colors.white70),
                ),
                Switch(
                  value: hasConfig,
                  activeColor: widget.accentColor,
                  onChanged: (val) {
                    setState(() {
                      if (val) {
                        widget.field.serialPrefix = '';
                        widget.field.serialSuffix = '';
                      } else {
                        widget.field.serialPrefix = null;
                        widget.field.serialSuffix = null;
                      }
                    });
                  },
                ),
              ],
            ),
            if (hasConfig)
              Row(
                children: [
                  Expanded(
                    child: _buildSmallInput(
                      initialValue: widget.field.serialPrefix,
                      label: 'Prefix (e.g. INV-)',
                      onChanged: (val) => widget.field.serialPrefix = val,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallInput(
                      initialValue: widget.field.serialSuffix,
                      label: 'Suffix',
                      onChanged: (val) => widget.field.serialSuffix = val,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInput({
    String? initialValue,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        isDense: true,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _getTypeLabel(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.string:
        return 'Text';
      case CustomFieldType.number:
        return 'Number';
      case CustomFieldType.date:
        return 'Date';
      case CustomFieldType.currency:
        return 'Currency';
      case CustomFieldType.dropdown:
        return 'Dropdown';
      case CustomFieldType.serial:
        return 'Serial No';
      case CustomFieldType.formula:
        return 'Formula (Math)';
    }
  }

  IconData _getTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.string:
        return Icons.text_fields;
      case CustomFieldType.number:
        return Icons.dialpad;
      case CustomFieldType.date:
        return Icons.calendar_month;
      case CustomFieldType.currency:
        return Icons.currency_rupee;
      case CustomFieldType.dropdown:
        return Icons.list_alt;
      case CustomFieldType.serial:
        return Icons.tag;
      case CustomFieldType.formula:
        return Icons.functions;
    }
  }
}
