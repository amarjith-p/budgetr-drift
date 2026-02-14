import 'package:budget/core/design/budgetr_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/models/custom_data_models.dart';
import '../services/custom_entry_service.dart';
import '../widgets/editor/field_config_card.dart';

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
          dropdownOptions:
              f.dropdownOptions != null ? List.from(f.dropdownOptions!) : null,
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
        createdAt: widget.templateToEdit?.createdAt ?? DateTime.now(),
      );

      try {
        if (_isEditing) {
          await GetIt.I<CustomEntryService>().updateCustomTemplate(template);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Updating & Backfilling data...")),
            );
          }
        } else {
          await GetIt.I<CustomEntryService>().addCustomTemplate(template);
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
      // [FIX] This ensures the layout resizes when the keyboard opens
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Sheet' : 'Design New Sheet',
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
                label: 'Sheet Name',
                icon: Icons.title,
                onSaved: (val) => _screenName = val!,
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(
                  bottom:
                      20, // Reduced bottom padding as buttons are now separate
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
                  return FieldConfigCard(
                    key: ValueKey(_fields[index]),
                    index: index,
                    field: _fields[index],
                    allFields: _fields,
                    onRemove: () => _removeField(index),
                    cardColor: _cardColor,
                    accentColor: _accentColor,
                    bgColor: _bgColor,
                  );
                },
              ),
            ),
            // [FIX] Bottom Control Bar - moved into the Column to ride up with keyboard
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _bgColor,
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ]),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Add Field Button (Replaces FAB)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _addField,
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.white),
                        label: const Text("Add Field",
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.4))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Save Button
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isEditing ? 'Update Tracker' : 'Save Tracker',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // [FIX] Removed FAB and BottomNavigationBar to prevent overlapping/hiding
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
}
