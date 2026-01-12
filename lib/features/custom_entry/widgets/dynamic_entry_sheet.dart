import 'package:budget/core/widgets/calculator_keyboard.dart';
import 'package:budget/core/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  final ScrollController _scrollController = ScrollController();

  TextEditingController? _activeCalcController;
  FocusNode? _activeFocusNode;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;
  bool _isEditing = false;

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
    _scrollController.dispose();
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

      if (field.type == CustomFieldType.number ||
          field.type == CustomFieldType.currency) {
        _controllers[field.name]?.addListener(_recalculateFormulas);
      }
    }
    // Initial Calc
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalculateFormulas());
  }

  // --- FORMULA ENGINE ---
  void _recalculateFormulas() {
    final formulaFields = widget.template.fields
        .where(
          (f) =>
              f.type == CustomFieldType.formula && f.formulaExpression != null,
        )
        .toList();

    if (formulaFields.isEmpty) return;

    for (var field in formulaFields) {
      String expr = field.formulaExpression!;

      for (var inputField in widget.template.fields) {
        String placeholder = '[${inputField.name}]';
        if (expr.contains(placeholder)) {
          if (_controllers.containsKey(inputField.name)) {
            double val =
                double.tryParse(_controllers[inputField.name]!.text) ?? 0.0;
            String replacement = val < 0 ? "($val)" : val.toString();
            expr = expr.replaceAll(placeholder, replacement);
          } else {
            expr = expr.replaceAll(placeholder, '0');
          }
        }
      }

      try {
        final result = _evaluateRPN(expr);
        final formatted =
            result.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');

        if (_controllers[field.name]!.text != formatted) {
          _controllers[field.name]!.text = formatted;
        }
      } catch (e) {
        // debugPrint('Calc Error: $e');
      }
    }
  }

  double _evaluateRPN(String expr) {
    expr = expr.replaceAll(' ', '');
    final tokens = _tokenize(expr);
    if (tokens.isEmpty) return 0.0;

    final outputQueue = <String>[];
    final operatorStack = <String>[];
    final precedence = {'+': 1, '-': 1, '*': 2, '/': 2};

    for (var token in tokens) {
      if (double.tryParse(token) != null) {
        outputQueue.add(token);
      } else if (token == '(') {
        operatorStack.add(token);
      } else if (token == ')') {
        while (operatorStack.isNotEmpty && operatorStack.last != '(') {
          outputQueue.add(operatorStack.removeLast());
        }
        if (operatorStack.isNotEmpty) operatorStack.removeLast();
      } else if (precedence.containsKey(token)) {
        while (operatorStack.isNotEmpty &&
            operatorStack.last != '(' &&
            precedence[operatorStack.last]! >= precedence[token]!) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }
    while (operatorStack.isNotEmpty) {
      outputQueue.add(operatorStack.removeLast());
    }

    final evalStack = <double>[];
    for (var token in outputQueue) {
      if (double.tryParse(token) != null) {
        evalStack.add(double.parse(token));
      } else {
        if (evalStack.length < 2) return 0.0;
        final b = evalStack.removeLast();
        final a = evalStack.removeLast();
        switch (token) {
          case '+':
            evalStack.add(a + b);
            break;
          case '-':
            evalStack.add(a - b);
            break;
          case '*':
            evalStack.add(a * b);
            break;
          case '/':
            evalStack.add(b == 0 ? 0 : a / b);
            break;
        }
      }
    }
    return evalStack.isNotEmpty ? evalStack.last : 0.0;
  }

  List<String> _tokenize(String expr) {
    List<String> tokens = [];
    String buffer = '';

    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];
      if ('+-*/()'.contains(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer);
          buffer = '';
        }
        if (char == '-' && (tokens.isEmpty || '+-*/('.contains(tokens.last))) {
          buffer += char;
        } else {
          tokens.add(char);
        }
      } else {
        buffer += char;
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer);
    return tokens;
  }

  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
    _scrollToInput(node);
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

  // --- UNIFIED NAVIGATION (Next & Back) ---
  void _navigateRelative(String currentFieldName, int step) {
    // 1. Identify all navigable input fields (String, Number, Currency)
    final inputFields = widget.template.fields
        .where(
          (f) =>
              f.type == CustomFieldType.string ||
              f.type == CustomFieldType.number ||
              f.type == CustomFieldType.currency,
        )
        .toList();

    // 2. Find current index
    final currentIndex = inputFields.indexWhere(
      (f) => f.name == currentFieldName,
    );

    // 3. Move relative
    if (currentIndex != -1) {
      final targetIndex = currentIndex + step;

      // Check bounds
      if (targetIndex >= 0 && targetIndex < inputFields.length) {
        final targetField = inputFields[targetIndex];
        final targetNode = _focusNodes[targetField.name]!;
        final targetController = _controllers[targetField.name]!;

        if (targetField.type == CustomFieldType.number ||
            targetField.type == CustomFieldType.currency) {
          // Go to Custom Keyboard (or System if toggled)
          _setActive(targetController, targetNode);
        } else {
          // Go to System Keyboard (for Text)
          setState(() {
            _isKeyboardVisible = false;
            _activeFocusNode = targetNode;
          });
          FocusScope.of(context).requestFocus(targetNode);
          _scrollToInput(targetNode);
        }
      } else {
        // Out of bounds (start or end), close keyboard
        _closeKeyboard();
      }
    }
  }

  // Handlers for Custom Keyboard
  void _handleNext() {
    if (_activeFocusNode == null) return;
    String? currentName = _findActiveFieldName();
    if (currentName != null) {
      _navigateRelative(currentName, 1);
    } else {
      _closeKeyboard();
    }
  }

  void _handlePrevious() {
    if (_activeFocusNode == null) return;
    String? currentName = _findActiveFieldName();
    if (currentName != null) {
      _navigateRelative(currentName, -1);
    } else {
      _closeKeyboard();
    }
  }

  String? _findActiveFieldName() {
    for (var entry in _focusNodes.entries) {
      if (entry.value == _activeFocusNode) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> _save() async {
    // --- VALIDATION FOR EMPTY DEPENDENCIES ---
    List<String> warnings = [];
    final formulas = widget.template.fields.where(
      (f) => f.type == CustomFieldType.formula && f.formulaExpression != null,
    );

    for (var f in formulas) {
      String expr = f.formulaExpression!;
      for (var inputField in widget.template.fields) {
        if (expr.contains('[${inputField.name}]')) {
          if (_controllers.containsKey(inputField.name) &&
              _controllers[inputField.name]!.text.trim().isEmpty) {
            warnings.add("'${inputField.name}' is empty (used in '${f.name}')");
          }
        }
      }
    }

    if (warnings.isNotEmpty) {
      warnings = warnings.toSet().toList();
      final shouldProceed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xff0D1B2A),
              icon: const Icon(
                Icons.warning_amber_sharp,
                color: Colors.amber,
                size: 40,
              ),
              title: const Text(
                "Missing Values",
                style: TextStyle(color: Colors.redAccent),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Some of the fields are empty but It is used in formulas. Empty Field(s) will recorded as 0 if not provided.",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "\nMissing Value(s):\n",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  ...warnings.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              w,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                  ),
                  child: const Text("Save Anyway",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ) ??
          false;

      if (!shouldProceed) return;
    }

    for (var field in widget.template.fields) {
      if (field.type == CustomFieldType.number ||
          field.type == CustomFieldType.currency ||
          field.type == CustomFieldType.formula) {
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
      await GetIt.I<CustomEntryService>().updateCustomRecord(record);
    } else {
      await GetIt.I<CustomEntryService>().addCustomRecord(record);
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
      // Fix for System Keyboard Pushing Content
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
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
              controller: _scrollController,
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
            // FIX: Instantly collapse custom keyboard if System Keyboard (viewInsets > 0) is opening.
            // This prevents "Double Keyboard Height" overflow during transition.
            duration: MediaQuery.of(context).viewInsets.bottom > 0
                ? Duration.zero
                : const Duration(milliseconds: 250),
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
                    onPrevious: _handlePrevious, // Handle Back button
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

    final isNum = field.type == CustomFieldType.number ||
        field.type == CustomFieldType.currency;
    final isSerial = field.type == CustomFieldType.serial;
    final isFormula = field.type == CustomFieldType.formula;

    // Determine if this is the last navigable field
    final inputFields = widget.template.fields
        .where(
          (f) =>
              f.type == CustomFieldType.string ||
              f.type == CustomFieldType.number ||
              f.type == CustomFieldType.currency,
        )
        .toList();
    final isLastInput =
        inputFields.isNotEmpty && inputFields.last.name == field.name;

    IconData inputIcon = Icons.text_fields;
    if (isSerial)
      inputIcon = Icons.tag;
    else if (field.type == CustomFieldType.currency)
      inputIcon = Icons.currency_rupee;
    else if (field.type == CustomFieldType.number)
      inputIcon = Icons.dialpad;
    else if (isFormula) inputIcon = Icons.functions;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[field.name],
        focusNode: _focusNodes[field.name],
        showCursor: !isFormula,

        readOnly: isSerial || isFormula
            ? true
            : (isNum ? !_useSystemKeyboard : false),

        keyboardType: isNum ? TextInputType.number : TextInputType.text,

        // --- AUTO NAVIGATION ---
        textInputAction:
            isLastInput ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) => _navigateRelative(field.name, 1),

        // -----------------------
        style: TextStyle(
          color: (isSerial || isFormula) ? Colors.white70 : Colors.white,
          fontWeight: isFormula ? FontWeight.bold : FontWeight.normal,
        ),

        onTap: (isNum && !isSerial && !isFormula)
            ? () => _setActive(
                  _controllers[field.name]!,
                  _focusNodes[field.name]!,
                )
            : () => setState(() => _isKeyboardVisible = false),

        decoration: InputDecoration(
          labelText: field.name,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixText: field.type == CustomFieldType.currency
              ? '${field.currencySymbol ?? '₹'} '
              : (isSerial ? field.serialPrefix : null),
          suffixText: isSerial ? field.serialSuffix : null,
          prefixIcon: Icon(
            inputIcon,
            color: (isSerial || isFormula)
                ? _accentColor.withOpacity(0.5)
                : _accentColor,
          ),
          filled: true,
          fillColor: isFormula ? _accentColor.withOpacity(0.1) : _inputColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: isFormula
                ? BorderSide(color: _accentColor.withOpacity(0.3))
                : BorderSide.none,
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
