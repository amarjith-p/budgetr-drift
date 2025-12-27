import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/custom_data_models.dart';
import '../services/custom_entry_service.dart';

class TemplateEditorScreen extends StatefulWidget {
  final CustomTemplate? templateToEdit;

  const TemplateEditorScreen({super.key, this.templateToEdit});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _screenName = '';
  List<CustomFieldConfig> _fields = [];
  bool _isEditing = false;

  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.8);
  final Color _accentColor = const Color(0xFF3A86FF);

  @override
  void initState() {
    super.initState();
    if (widget.templateToEdit != null) {
      _isEditing = true;
      _screenName = widget.templateToEdit!.name;
      _fields = widget.templateToEdit!.fields.map((f) {
        return CustomFieldConfig(
          name: f.name,
          type: f.type,
          isSumRequired: f.isSumRequired,
          currencySymbol: f.currencySymbol,
          dropdownOptions: f.dropdownOptions != null
              ? List.from(f.dropdownOptions!)
              : null,
          serialPrefix: f.serialPrefix,
          serialSuffix: f.serialSuffix,
          formulaExpression: f.formulaExpression,
        );
      }).toList();
    }
  }

  void _addField() {
    setState(() {
      _fields.add(CustomFieldConfig(name: '', type: CustomFieldType.string));
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_screenName.trim().endsWith('AutoTracker')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Name cannot end with 'AutoTracker'. This is reserved for system-generated sheets.",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      if (_fields.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Add at least one field")));
        return;
      }

      final template = CustomTemplate(
        id: widget.templateToEdit?.id ?? '',
        name: _screenName,
        fields: _fields,
        xAxisField: widget.templateToEdit?.xAxisField,
        yAxisField: widget.templateToEdit?.yAxisField,
        // Preserve original createdAt on edit, or use now() for new
        createdAt: widget.templateToEdit?.createdAt ?? DateTime.now(),
      );

      try {
        if (_isEditing) {
          await CustomEntryService().updateCustomTemplate(template);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Updating & Backfilling data...")),
            );
          }
        } else {
          await CustomEntryService().addCustomTemplate(template);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error saving form: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Tracker' : 'Design New Tracker',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildStyledTextField(
                initialValue: _screenName,
                label: 'Tracker Name',
                icon: Icons.title,
                onSaved: (val) => _screenName = val!,
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
                itemCount: _fields.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _fields.removeAt(oldIndex);
                    _fields.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return _buildFieldCard(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'template_editor_fab',
        backgroundColor: _accentColor,
        onPressed: _addField,
        label: const Text(
          'Add Field',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_circle_outline),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              _isEditing ? 'Update Tracker' : 'Save Tracker',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard(int index) {
    return Container(
      key: ValueKey(_fields[index]),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
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
                  initialValue: _fields[index].name,
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
                  onChanged: (val) => _fields[index].name = val,
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
                onPressed: () => _removeField(index),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          Row(
            children: [
              Expanded(
                child: ModernDropdownPill<CustomFieldType>(
                  label: _getTypeLabel(_fields[index].type),
                  isActive: true,
                  icon: _getTypeIcon(_fields[index].type),
                  onTap: () => showSelectionSheet<CustomFieldType>(
                    context: context,
                    title: 'Field Type',
                    items: CustomFieldType.values,
                    labelBuilder: (t) => _getTypeLabel(t),
                    onSelect: (val) {
                      setState(() => _fields[index].type = val!);
                    },
                    selectedItem: _fields[index].type,
                  ),
                ),
              ),
            ],
          ),
          if (_fields[index].type == CustomFieldType.number ||
              _fields[index].type == CustomFieldType.currency)
            _buildNumberConfig(index),
          if (_fields[index].type == CustomFieldType.dropdown)
            _DropdownInputBlock(
              field: _fields[index],
              accentColor: _accentColor,
            ),
          if (_fields[index].type == CustomFieldType.serial)
            _buildSerialConfig(index),
          if (_fields[index].type == CustomFieldType.formula)
            _FormulaInputBlock(
              field: _fields[index],
              allFields: _fields,
              accentColor: _accentColor,
            ),
        ],
      ),
    );
  }

  Widget _buildNumberConfig(int index) {
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
              value: _fields[index].isSumRequired,
              activeColor: _accentColor,
              onChanged: (val) =>
                  setState(() => _fields[index].isSumRequired = val!),
            ),
            const Text(
              'Calculate Total',
              style: TextStyle(color: Colors.white70),
            ),
            if (_fields[index].type == CustomFieldType.currency) ...[
              const Spacer(),
              DropdownButton<String>(
                value: _fields[index].currencySymbol ?? '₹',
                dropdownColor: _bgColor,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: ['₹', '\$', '€', '£']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _fields[index].currencySymbol = val),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSerialConfig(int index) {
    bool hasConfig =
        _fields[index].serialPrefix != null ||
        _fields[index].serialSuffix != null;
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
                  activeColor: _accentColor,
                  onChanged: (val) {
                    setState(() {
                      if (val) {
                        _fields[index].serialPrefix = '';
                        _fields[index].serialSuffix = '';
                      } else {
                        _fields[index].serialPrefix = null;
                        _fields[index].serialSuffix = null;
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
                      initialValue: _fields[index].serialPrefix,
                      label: 'Prefix (e.g. INV-)',
                      onChanged: (val) => _fields[index].serialPrefix = val,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallInput(
                      initialValue: _fields[index].serialSuffix,
                      label: 'Suffix',
                      onChanged: (val) => _fields[index].serialSuffix = val,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required String initialValue,
    required String label,
    IconData? icon,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: _accentColor) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      onSaved: onSaved,
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
        labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
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

// --- DROPDOWN INPUT BLOCK (Extracted to fix clearing issue) ---
class _DropdownInputBlock extends StatefulWidget {
  final CustomFieldConfig field;
  final Color accentColor;

  const _DropdownInputBlock({required this.field, required this.accentColor});

  @override
  State<_DropdownInputBlock> createState() => _DropdownInputBlockState();
}

class _DropdownInputBlockState extends State<_DropdownInputBlock> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    final val = _controller.text.trim();
    if (val.isNotEmpty) {
      setState(() {
        (widget.field.dropdownOptions ??= []).add(val);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (widget.field.dropdownOptions ?? [])
                .map(
                  (opt) => Chip(
                    label: Text(
                      opt,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: widget.accentColor.withOpacity(0.2),
                    deleteIconColor: Colors.white70,
                    onDeleted: () => setState(
                      () => widget.field.dropdownOptions!.remove(opt),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add option...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black12,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onFieldSubmitted: (_) => _addOption(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: widget.accentColor),
                onPressed: _addOption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- FORMULA BUILDER (Reordered Numbers) ---
class _FormulaInputBlock extends StatefulWidget {
  final CustomFieldConfig field;
  final List<CustomFieldConfig> allFields;
  final Color accentColor;

  const _FormulaInputBlock({
    required this.field,
    required this.allFields,
    required this.accentColor,
  });

  @override
  State<_FormulaInputBlock> createState() => _FormulaInputBlockState();
}

class _FormulaInputBlockState extends State<_FormulaInputBlock> {
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

            // --- FIELDS ---
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

            // --- OPERATORS ---
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

            // --- NUMBERS (Sequential Order) ---
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
