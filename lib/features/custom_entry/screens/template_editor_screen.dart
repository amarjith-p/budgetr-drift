import 'package:budget/features/dashboard/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';

class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _screenName = '';
  List<CustomFieldConfig> _fields = [];

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
        id: '',
        name: _screenName,
        fields: _fields,
      );
      await FirestoreService().addCustomTemplate(template);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design New Form')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Screen Name (e.g. Daily Expenses)',
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
                      vertical: 4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 36),
                              Expanded(
                                child: ModernDropdownPill<CustomFieldType>(
                                  label: _fields[index].type.name.toUpperCase(),
                                  isActive: true,
                                  icon: Icons.category,
                                  onTap: () =>
                                      showSelectionSheet<CustomFieldType>(
                                        context: context,
                                        title: 'Field Type',
                                        items: CustomFieldType.values,
                                        labelBuilder: (t) =>
                                            t.name.toUpperCase(),
                                        onSelect: (val) => setState(
                                          () => _fields[index].type = val!,
                                        ),
                                        selectedItem: _fields[index].type,
                                      ),
                                ),
                              ),
                              if (_fields[index].type == CustomFieldType.number)
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _fields[index].isSumRequired,
                                      onChanged: (val) => setState(
                                        () =>
                                            _fields[index].isSumRequired = val!,
                                      ),
                                    ),
                                    const Text('Total?'),
                                  ],
                                ),
                            ],
                          ),
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
          child: const Text('Create Screen'),
        ),
      ),
    );
  }
}
