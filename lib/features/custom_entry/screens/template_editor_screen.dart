import 'package:budget/features/dashboard/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';

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
          await FirestoreService().updateCustomTemplate(template);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Updating & Backfilling data...")),
            );
          }
        } else {
          await FirestoreService().addCustomTemplate(template);
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Form' : 'Design New Form')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                initialValue: _screenName,
                decoration: const InputDecoration(
                  labelText: 'Screen Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _screenName = val!,
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _fields.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _fields.removeAt(oldIndex);
                    _fields.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return Card(
                    key: ValueKey(_fields[index]),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.drag_handle, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _fields[index].name,
                                  decoration: const InputDecoration(
                                    labelText: 'Field Name',
                                    isDense: true,
                                  ),
                                  onChanged: (val) => _fields[index].name = val,
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _removeField(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(width: 36),
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
                                      // Block String -> Number conversion
                                      if (_isEditing &&
                                          _originalTypes.containsKey(
                                            _fields[index].name,
                                          )) {
                                        final oldType =
                                            _originalTypes[_fields[index]
                                                .name]!;
                                        if (oldType == CustomFieldType.string &&
                                            (val == CustomFieldType.number ||
                                                val ==
                                                    CustomFieldType.currency)) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                      setState(
                                        () => _fields[index].type = val!,
                                      );
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addField,
        label: const Text('Add Field'),
        icon: const Icon(Icons.add_circle_outline),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: Text(_isEditing ? 'Update Form' : 'Create Form'),
        ),
      ),
    );
  }

  Widget _buildNumberConfig(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 8),
      child: Row(
        children: [
          Checkbox(
            value: _fields[index].isSumRequired,
            onChanged: (val) =>
                setState(() => _fields[index].isSumRequired = val!),
          ),
          const Text('Total?'),
          if (_fields[index].type == CustomFieldType.currency) ...[
            const Spacer(),
            const Text("Symbol: "),
            DropdownButton<String>(
              value: _fields[index].currencySymbol ?? '₹',
              underline: Container(),
              items: [
                '₹',
                '\$',
                '€',
                '£',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) =>
                  setState(() => _fields[index].currencySymbol = val),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSerialConfig(int index) {
    // FIX: Check for nullability only.
    // We want the switch to be ON if the value is defined (even if empty string)
    // We only want it OFF if the value is null.
    bool hasConfig =
        _fields[index].serialPrefix != null ||
        _fields[index].serialSuffix != null;

    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  "Auto-Increment Options: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Custom Format?", style: TextStyle(fontSize: 12)),
                  Switch(
                    value: hasConfig,
                    onChanged: (val) {
                      setState(() {
                        if (val) {
                          // Initialize as empty strings (not null) so fields appear
                          _fields[index].serialPrefix = '';
                          _fields[index].serialSuffix = '';
                        } else {
                          // Set to null to hide fields
                          _fields[index].serialPrefix = null;
                          _fields[index].serialSuffix = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (hasConfig)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _fields[index].serialPrefix,
                    decoration: const InputDecoration(
                      labelText: 'Prefix (e.g. INV-)',
                      isDense: true,
                    ),
                    onChanged: (val) => _fields[index].serialPrefix = val,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _fields[index].serialSuffix,
                    decoration: const InputDecoration(
                      labelText: 'Suffix',
                      isDense: true,
                    ),
                    onChanged: (val) => _fields[index].serialSuffix = val,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          const Text(
            "Existing data will be auto-numbered (1, 2, 3...)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownConfig(int index) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: (_fields[index].dropdownOptions ?? [])
                .map(
                  (opt) => Chip(
                    label: Text(opt),
                    onDeleted: () => setState(
                      () => _fields[index].dropdownOptions!.remove(opt),
                    ),
                  ),
                )
                .toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Add option',
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty)
                      setState(
                        () => (_fields[index].dropdownOptions ??= []).add(val),
                      );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (controller.text.isNotEmpty)
                    setState(
                      () => (_fields[index].dropdownOptions ??= []).add(
                        controller.text,
                      ),
                    );
                },
              ),
            ],
          ),
        ],
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
        return 'Serial No (Auto)';
    }
  }

  IconData _getTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.string:
        return Icons.text_fields;
      case CustomFieldType.number:
        return Icons.onetwothree;
      case CustomFieldType.date:
        return Icons.calendar_today;
      case CustomFieldType.currency:
        return Icons.attach_money;
      case CustomFieldType.dropdown:
        return Icons.list;
      case CustomFieldType.serial:
        return Icons.tag;
    }
  }
}
