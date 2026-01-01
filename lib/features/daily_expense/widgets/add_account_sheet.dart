import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/bank_list.dart';
import '../models/expense_models.dart';

class AddAccountSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAccountAdded;
  final ExpenseAccountModel? accountToEdit;

  const AddAccountSheet({
    super.key,
    required this.onAccountAdded,
    this.accountToEdit,
  });

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _accountNoController;
  late TextEditingController _balanceController;

  // Focus Nodes for Enter-to-Next & Auto-Scroll
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _accNumFocus = FocusNode();
  final FocusNode _balanceFocus = FocusNode();

  // Global Keys to identify widgets for Auto-Scrolling
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _accNumFieldKey = GlobalKey();
  final GlobalKey _balanceFieldKey = GlobalKey();

  // Selections
  String? _selectedBank;
  String? _selectedAccountType;

  // Professional Financial Color Palette
  final List<Color> _accountColors = [
    const Color(0xFF1E1E1E), // Matte Black
    const Color(0xFF2C3E50), // Midnight Blue
    const Color(0xFF1A5276), // Deep Ocean
    const Color(0xFF004D40), // British Racing Green
    const Color(0xFF880E4F), // Royal Maroon
    const Color(0xFF4A148C), // Deep Purple
    const Color(0xFF37474F), // Slate Grey
    const Color(0xFFBF360C), // Burnt Orange
  ];
  late Color _selectedColor;

  final List<String> _accountTypes = ['Savings Account', 'Salary Account'];

  @override
  void initState() {
    super.initState();
    final edit = widget.accountToEdit;

    _nameController = TextEditingController(text: edit?.name ?? '');
    _accountNoController =
        TextEditingController(text: edit?.accountNumber ?? '');
    _balanceController = TextEditingController(
      text: edit != null ? edit.currentBalance.toStringAsFixed(0) : '',
    );

    _selectedBank = edit?.bankName;
    _selectedAccountType = edit?.accountType;

    if (edit != null && edit.color != 0) {
      _selectedColor = Color(edit.color);
    } else {
      _selectedColor = _accountColors[0];
    }

    // Attach Focus Listeners for Auto-Scroll
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) _scrollToField(_nameFieldKey);
    });
    _accNumFocus.addListener(() {
      if (_accNumFocus.hasFocus) _scrollToField(_accNumFieldKey);
    });
    _balanceFocus.addListener(() {
      if (_balanceFocus.hasFocus) _scrollToField(_balanceFieldKey);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountNoController.dispose();
    _balanceController.dispose();
    _nameFocus.dispose();
    _accNumFocus.dispose();
    _balanceFocus.dispose();
    super.dispose();
  }

  // --- AUTO SCROLL LOGIC ---
  void _scrollToField(GlobalKey key) {
    // Small delay to allow keyboard animation to start/finish
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5, // Center the field in the view
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newAccountData = {
        'name': _nameController.text.trim(),
        'bankName': _selectedBank,
        'accountType': _selectedAccountType,
        'accountNumber': _accountNoController.text.trim(),
        'currentBalance':
            double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0.0,
        'color': _selectedColor.value,
        'type': 'Bank',
      };

      widget.onAccountAdded(newAccountData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0D1B2A);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.accountToEdit != null;

    return Container(
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isEditing ? "Edit Account" : "New Account",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Account Name
              _buildTextField(
                fieldKey: _nameFieldKey,
                controller: _nameController,
                focusNode: _nameFocus,
                label: "Account Name",
                hint: "e.g. Personal Savings",
                icon: Icons.edit_outlined,
                inputAction: TextInputAction.next,
                // Skip Dropdowns, jump to Account Number
                onSubmitted: () =>
                    FocusScope.of(context).requestFocus(_accNumFocus),
              ),

              const SizedBox(height: 16),

              // 2. Row: Bank & Account Type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSelectField<String>(
                      label: "Bank",
                      value: _selectedBank,
                      items: BankConstants.indianBanks,
                      labelBuilder: (val) => val,
                      onSelect: (val) => setState(() => _selectedBank = val),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectField<String>(
                      label: "Type",
                      value: _selectedAccountType,
                      items: _accountTypes,
                      labelBuilder: (val) => val,
                      onSelect: (val) =>
                          setState(() => _selectedAccountType = val),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. Account Number
              _buildTextField(
                fieldKey: _accNumFieldKey,
                controller: _accountNoController,
                focusNode: _accNumFocus,
                label: "Last 4 Digits of Account No",
                hint: "e.g. 8842",
                icon: Icons.numbers,
                inputType: TextInputType.number,
                maxLength: 4,
                isDigitOnly: true,
                inputAction: TextInputAction.next,
                onSubmitted: () =>
                    FocusScope.of(context).requestFocus(_balanceFocus),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length != 4) return 'Enter exactly 4 digits';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 4. Current Balance
              _buildTextField(
                fieldKey: _balanceFieldKey,
                controller: _balanceController,
                focusNode: _balanceFocus,
                label: "Current Balance",
                hint: "₹ 0.00",
                icon: Icons.currency_rupee,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                inputAction: TextInputAction.done,
                onSubmitted: () => _submit(),
              ),

              const SizedBox(height: 24),

              // --- COLOR PICKER ---
              Text(
                "Card Color",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _accountColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final color = _accountColors[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? "Update Account" : "Add Account",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
      counterText: "",
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    GlobalKey? fieldKey, // Key for scrolling
    FocusNode? focusNode, // Focus Node for management
    TextInputAction? inputAction, // Enter Key Action
    VoidCallback? onSubmitted, // Action on Enter
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    bool isDigitOnly = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      key: fieldKey, // Attach Key here so Scrollable finds this widget
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: inputType,
        textInputAction: inputAction,
        onFieldSubmitted: (_) => onSubmitted?.call(),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        maxLength: maxLength,
        inputFormatters: isDigitOnly
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxLength),
              ]
            : null,
        validator: validator ??
            (val) => val == null || val.isEmpty ? 'Required' : null,
        decoration: _inputDeco(label).copyWith(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon:
              Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
        ),
      ),
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
              onTap: () {
                // Clear text focus before opening sheet
                _nameFocus.unfocus();
                _accNumFocus.unfocus();
                _balanceFocus.unfocus();

                _showSelectionSheet<T>(
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
                );
              },
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

  void _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    T? selectedItem,
    required String Function(T) labelBuilder,
    required Function(T) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xff1B263B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = item == selectedItem;
                        return ListTile(
                          onTap: () {
                            onSelect(item);
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: isSelected
                              ? const Color(0xFF00B4D8).withOpacity(0.2)
                              : Colors.transparent,
                          title: Text(
                            labelBuilder(item),
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00B4D8)
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: Color(0xFF00B4D8))
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
