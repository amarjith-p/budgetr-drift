import 'package:flutter/material.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';
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
  final Map<String, CustomFieldType> _originalTypes = {};

  // Theme Colors
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
        _originalTypes[f.name] = f.type;
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
              Icon(Icons.drag_indicator, color: Colors.white24),
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
                    hintText: 'Field Name (e.g. Amount, Date)',
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
                      if (_isEditing &&
                          _originalTypes.containsKey(_fields[index].name)) {
                        final oldType = _originalTypes[_fields[index].name]!;
                        if (oldType == CustomFieldType.string &&
                            (val == CustomFieldType.number ||
                                val == CustomFieldType.currency)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Cannot change Text to Number/Currency.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }
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
            _buildDropdownConfig(index),
          if (_fields[index].type == CustomFieldType.serial)
            _buildSerialConfig(index),
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

  Widget _buildDropdownConfig(int index) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_fields[index].dropdownOptions ?? [])
                .map(
                  (opt) => Chip(
                    label: Text(
                      opt,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _accentColor.withOpacity(0.2),
                    deleteIconColor: Colors.white70,
                    onDeleted: () => setState(
                      () => _fields[index].dropdownOptions!.remove(opt),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add option...',
                    hintStyle: TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black12,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty)
                      setState(
                        () => (_fields[index].dropdownOptions ??= []).add(val),
                      );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: _accentColor),
                onPressed: () {
                  if (controller.text.isNotEmpty)
                    setState(
                      () => (_fields[index].dropdownOptions ??= []).add(
                        controller.text,
                      ),
                    );
                  controller.clear();
                },
              ),
            ],
          ),
        ],
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
        enabledBorder: OutlineInputBorder(
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
    }
  }

  IconData _getTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.string:
        return Icons.text_fields;
      case CustomFieldType.number:
        return Icons.dialpad; // CHANGED TO DIALPAD
      case CustomFieldType.date:
        return Icons.calendar_month;
      case CustomFieldType.currency:
        return Icons.currency_rupee; // CHANGED TO RUPEE
      case CustomFieldType.dropdown:
        return Icons.list_alt;
      case CustomFieldType.serial:
        return Icons.tag;
    }
  }
}
