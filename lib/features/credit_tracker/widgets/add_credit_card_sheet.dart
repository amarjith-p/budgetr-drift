import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/bank_list.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/widgets/calculator_keyboard.dart'; // Import Custom Keyboard
import '../models/credit_models.dart';
import '../services/credit_service.dart';

class AddCreditCardSheet extends StatefulWidget {
  final CreditCardModel? cardToEdit;

  const AddCreditCardSheet({super.key, this.cardToEdit});

  @override
  State<AddCreditCardSheet> createState() => _AddCreditCardSheetState();
}

class _AddCreditCardSheetState extends State<AddCreditCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();

  // Focus Nodes
  final FocusNode _nameNode = FocusNode();
  final FocusNode _limitNode = FocusNode();

  // Keys for Auto-Scroll
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _limitFieldKey = GlobalKey();

  String? _selectedBank;
  int _billDate = 1;
  int _dueDate = 5;
  bool _isLoading = false;
  bool _showCustomKeyboard = false;
  // ADDED: State to track keyboard type
  bool _systemKeyboardActive = false;

  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF3A86FF);

  @override
  void initState() {
    super.initState();
    if (widget.cardToEdit != null) {
      _loadExistingData();
    }

    // Listeners for Focus Logic
    _nameNode.addListener(() {
      if (_nameNode.hasFocus) {
        setState(() => _showCustomKeyboard = false);
        _scrollToField(_nameFieldKey);
      }
    });

    _limitNode.addListener(() {
      if (_limitNode.hasFocus) {
        if (!_systemKeyboardActive) {
          setState(() => _showCustomKeyboard = true);
        }
        _scrollToField(_limitFieldKey);
      }
    });
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _limitNode.dispose();
    _nameCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  void _scrollToField(GlobalKey key) {
    // Small delay to allow keyboard animation to start
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5, // Center the field
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _loadExistingData() {
    final c = widget.cardToEdit!;
    _nameCtrl.text = c.name;
    _limitCtrl.text =
        c.creditLimit.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    _selectedBank = c.bankName;
    _billDate = c.billDate;
    _dueDate = c.dueDate;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isEditing = widget.cardToEdit != null;

      final card = CreditCardModel(
        id: isEditing ? widget.cardToEdit!.id : '',
        name: _nameCtrl.text,
        bankName: _selectedBank!,
        creditLimit: double.parse(_limitCtrl.text),
        billDate: _billDate,
        dueDate: _dueDate,
        createdAt:
            isEditing ? widget.cardToEdit!.createdAt : DateTime.timestamp(),
        currentBalance: isEditing ? widget.cardToEdit!.currentBalance : 0.0,
      );

      if (isEditing) {
        await GetIt.I<CreditService>().updateCreditCard(card);
      } else {
        await GetIt.I<CreditService>().addCreditCard(card);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjust bottom padding
    final bottomPadding =
        _showCustomKeyboard ? 0.0 : MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SCROLLABLE FORM CONTENT
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.cardToEdit != null
                          ? "Edit Credit Card"
                          : "New Credit Card",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card Name (System Keyboard)
                    TextFormField(
                      key: _nameFieldKey,
                      focusNode: _nameNode,
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Card Name (e.g. Regalia Gold)'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_limitNode);
                      },
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildSelectField<String>(
                      label: "Bank Name",
                      value: _selectedBank,
                      items: BankConstants.indianBanks,
                      labelBuilder: (v) => v,
                      onSelect: (v) => setState(() => _selectedBank = v),
                      validator: (v) =>
                          v == null ? 'Please select a bank' : null,
                    ),
                    const SizedBox(height: 16),

                    // Credit Limit (Custom Keyboard)
                    TextFormField(
                      key: _limitFieldKey,
                      focusNode: _limitNode,
                      controller: _limitCtrl,
                      // FIXED: Toggle based on system keyboard activity
                      keyboardType: _systemKeyboardActive
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.none,
                      showCursor: true,
                      readOnly: !_systemKeyboardActive,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Credit Limit'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      onTap: () {
                        if (!_limitNode.hasFocus) {
                          FocusScope.of(context).requestFocus(_limitNode);
                        }
                        setState(() {
                          _showCustomKeyboard = true;
                          _systemKeyboardActive = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectField<int>(
                            label: "Bill Date",
                            value: _billDate,
                            items: List.generate(31, (i) => i + 1),
                            labelBuilder: (v) => v.toString(),
                            onSelect: (v) => setState(() => _billDate = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSelectField<int>(
                            label: "Due Date",
                            value: _dueDate,
                            items: List.generate(31, (i) => i + 1),
                            labelBuilder: (v) => v.toString(),
                            onSelect: (v) => setState(() => _dueDate = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: ModernLoader(size: 24),
                              )
                            : Text(
                                widget.cardToEdit != null
                                    ? "Update Account"
                                    : "Create Account",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CUSTOM KEYBOARD AREA
          if (_showCustomKeyboard)
            CalculatorKeyboard(
              onKeyPress: (val) =>
                  CalculatorKeyboard.handleKeyPress(_limitCtrl, val),
              onBackspace: () => CalculatorKeyboard.handleBackspace(_limitCtrl),
              onClear: () => _limitCtrl.clear(),
              onEquals: () => CalculatorKeyboard.handleEquals(_limitCtrl),
              onClose: () {
                setState(() => _showCustomKeyboard = false);
                _limitNode.unfocus();
              },
              onPrevious: () {
                setState(() => _showCustomKeyboard = false);
                FocusScope.of(context).requestFocus(_nameNode);
              },
              onNext: () {
                setState(() => _showCustomKeyboard = false);
                _limitNode.unfocus();
              },
              // ADDED: System Keyboard Logic
              onSwitchToSystem: () {
                setState(() {
                  _showCustomKeyboard = false;
                  _systemKeyboardActive = true;
                });
                _limitNode.unfocus();
                Future.delayed(const Duration(milliseconds: 100), () {
                  FocusScope.of(context).requestFocus(_limitNode);
                });
              },
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSelectField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required Function(T) onSelect,
    String? Function(T?)? validator,
  }) {
    return FormField<T>(
      validator: validator,
      initialValue: value,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => showSelectionSheet<T>(
                context: context,
                title: "Select $label",
                items: items,
                selectedItem: value,
                labelBuilder: labelBuilder,
                onSelect: (v) {
                  if (v != null) {
                    onSelect(v);
                    state.didChange(v);
                  }
                },
              ),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _inputDeco(label).copyWith(
                  errorText: state.errorText,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                  ),
                ),
                isEmpty: value == null,
                child: Text(
                  value != null ? labelBuilder(value) : '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
