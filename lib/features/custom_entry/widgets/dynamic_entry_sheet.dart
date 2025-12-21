import 'package:budget/core/widgets/calculator_keyboard.dart';
import 'package:budget/core/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/custom_data_models.dart';
import '../services/custom_entry_service.dart';

class DynamicEntrySheet extends StatefulWidget {
  final CustomTemplate template;
  final List<CustomRecord> existingRecords;
  final CustomRecord? recordToEdit;

  const DynamicEntrySheet({
    super.key,
    required this.template,
    this.existingRecords = const [],
    this.recordToEdit,
  });

  @override
  State<DynamicEntrySheet> createState() => _DynamicEntrySheetState();
}

class _DynamicEntrySheetState extends State<DynamicEntrySheet> {
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  TextEditingController? _activeCalcController;
  FocusNode? _activeFocusNode;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;
  bool _isEditing = false;

  // Theme
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _inputColor = const Color(0xFF1B263B);
  final Color _accentColor = const Color(0xFF3A86FF);

  @override
  void initState() {
    super.initState();
    _isEditing = widget.recordToEdit != null;
    _initializeFields();
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    _focusNodes.values.forEach((f) => f.dispose());
    super.dispose();
  }

  void _initializeFields() {
    for (var field in widget.template.fields) {
      dynamic initialVal;
      if (_isEditing && widget.recordToEdit!.data.containsKey(field.name)) {
        initialVal = widget.recordToEdit!.data[field.name];
      }

      if (!_focusNodes.containsKey(field.name)) {
        _focusNodes[field.name] = FocusNode();
      }

      if (field.type == CustomFieldType.date) {
        if (initialVal is Timestamp)
          _formData[field.name] = initialVal.toDate();
        else if (initialVal is DateTime)
          _formData[field.name] = initialVal;
        else
          _formData[field.name] = DateTime.now();
      } else if (field.type == CustomFieldType.dropdown) {
        _formData[field.name] = initialVal;
      } else if (field.type == CustomFieldType.serial) {
        if (_isEditing) {
          _controllers[field.name] = TextEditingController(
            text: initialVal?.toString() ?? '',
          );
        } else {
          int maxSerial = 0;
          for (var r in widget.existingRecords) {
            var val = r.data[field.name];
            if (val is int && val > maxSerial) maxSerial = val;
          }
          int next = maxSerial + 1;
          _controllers[field.name] = TextEditingController(
            text: next.toString(),
          );
          _formData[field.name] = next;
        }
      } else {
        _controllers[field.name] = TextEditingController(
          text: initialVal?.toString() ?? '',
        );
      }
    }
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeCalcController = ctrl;
      _activeFocusNode = node;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystem() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    if (_activeFocusNode != null) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).requestFocus(_activeFocusNode);
      });
    }
  }

  void _handleNext() {
    if (_activeFocusNode == null) return;
    final fields = widget.template.fields
        .where(
          (f) =>
              f.type == CustomFieldType.number ||
              f.type == CustomFieldType.currency,
        )
        .toList();

    int currentIndex = -1;
    for (int i = 0; i < fields.length; i++) {
      if (_focusNodes[fields[i].name] == _activeFocusNode) {
        currentIndex = i;
        break;
      }
    }

    if (currentIndex != -1 && currentIndex < fields.length - 1) {
      final nextField = fields[currentIndex + 1];
      _setActive(_controllers[nextField.name]!, _focusNodes[nextField.name]!);
    } else {
      _closeKeyboard();
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
      } else if (field.type == CustomFieldType.serial) {
        _formData[field.name] =
            int.tryParse(_controllers[field.name]!.text) ?? 1;
      }
    }

    final record = CustomRecord(
      id: widget.recordToEdit?.id ?? '',
      templateId: widget.template.id,
      data: _formData,
      createdAt: widget.recordToEdit?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await CustomEntryService().updateCustomRecord(record);
    } else {
      await CustomEntryService().addCustomRecord(record);
    }
    if (mounted) Navigator.pop(context);
  }

  void _reset() {
    _controllers.values.forEach((c) => c.clear());
    setState(() {
      _formData.clear();
      _initializeFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Entry' : 'New ${widget.template.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isEditing)
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Colors.orange[300]),
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
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Update Entry' : 'Save Record',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                    onClose: _closeKeyboard,
                    onSwitchToSystem: _switchToSystem,
                    onNext: _handleNext,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(CustomFieldConfig field) {
    if (field.type == CustomFieldType.date) {
      final val = _formData[field.name] as DateTime? ?? DateTime.now();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: val,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: _accentColor,
                      surface: const Color(0xFF1B263B),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) setState(() => _formData[field.name] = picked);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: _inputColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: _accentColor),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy').format(val),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (field.type == CustomFieldType.dropdown) {
      final val = _formData[field.name];
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ModernDropdownPill<String>(
          label: val ?? 'Select ${field.name}',
          isActive: val != null,
          icon: Icons.expand_circle_down_outlined,
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

    final isNum =
        field.type == CustomFieldType.number ||
        field.type == CustomFieldType.currency;
    final isSerial = field.type == CustomFieldType.serial;

    // --- ICON LOGIC ---
    IconData inputIcon = Icons.text_fields;
    if (isSerial)
      inputIcon = Icons.tag;
    else if (field.type == CustomFieldType.currency)
      inputIcon = Icons.currency_rupee; // FIXED
    else if (field.type == CustomFieldType.number)
      inputIcon = Icons.dialpad; // FIXED

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[field.name],
        focusNode: _focusNodes[field.name],
        readOnly: isSerial ? true : (isNum ? !_useSystemKeyboard : false),
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: isSerial ? Colors.white38 : Colors.white),
        onTap: (isNum && !isSerial)
            ? () => _setActive(
                _controllers[field.name]!,
                _focusNodes[field.name]!,
              )
            : () => setState(() => _isKeyboardVisible = false),
        decoration: InputDecoration(
          labelText: field.name,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),

          // --- NULL CURRENCY FIX ---
          prefixText: field.type == CustomFieldType.currency
              ? '${field.currencySymbol ?? '₹'} '
              : (isSerial ? field.serialPrefix : null),

          suffixText: isSerial ? field.serialSuffix : null,
          prefixIcon: Icon(
            inputIcon,
            color: isSerial ? Colors.white24 : _accentColor,
          ),
          filled: true,
          fillColor: _inputColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _accentColor),
          ),
        ),
      ),
    );
  }
}
// 