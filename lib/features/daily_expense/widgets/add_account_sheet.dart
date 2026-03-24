import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/bank_list.dart';
import '../models/expense_models.dart';

class AddAccountSheet extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onAccountAdded;
  final ExpenseAccountModel? accountToEdit;
  final bool isCreditPoolAvailable;

  const AddAccountSheet({
    super.key,
    required this.onAccountAdded,
    this.accountToEdit,
    this.isCreditPoolAvailable = true,
  });

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _accountNoController;
  late TextEditingController _balanceController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _accNumFocus = FocusNode();
  final FocusNode _balanceFocus = FocusNode();

  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _accNumFieldKey = GlobalKey();
  final GlobalKey _balanceFieldKey = GlobalKey();

  String? _selectedBank;
  String? _selectedAccountType;
  bool _isLoading = false;

  final List<Color> _accountColors = [
    const Color(0xFF1E1E1E),
    const Color(0xFF2C3E50),
    const Color(0xFF1A5276),
    const Color(0xFF004D40),
    const Color(0xFF880E4F),
    const Color(0xFF4A148C),
    const Color(0xFF37474F),
    const Color(0xFFBF360C),
    const Color(0xFFB71C1C),
    const Color(0xFF0D47A1),
    const Color(0xFF1B5E20),
    const Color(0xFFF57F17),
    const Color(0xFF4E342E),
    const Color(0xFF006064),
    const Color(0xFF311B92),
  ];

  late Color _selectedColor;

  final List<String> _allAccountTypes = [
    'Savings Account',
    'Salary Account',
    'Current Account',
    'Wallet',
    'Cash',
    // 'Credit Card'
  ];

  List<String> get _availableAccountTypes {
    if (widget.isCreditPoolAvailable) {
      return _allAccountTypes;
    }
    return _allAccountTypes.where((t) => t != 'Credit Card').toList();
  }

  @override
  void initState() {
    super.initState();
    final edit = widget.accountToEdit;

    _nameController = TextEditingController(text: edit?.name ?? '');
    _accountNoController =
        TextEditingController(text: edit?.accountNumber ?? '');
    _balanceController = TextEditingController(
      text: edit != null
          ? edit.currentBalance
              .toString()
              .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "")
          : '',
    );

    _selectedBank = edit?.bankName;
    _selectedAccountType = edit?.accountType;

    if (edit != null && edit.color != 0) {
      _selectedColor = Color(edit.color);
    } else {
      _selectedColor = _accountColors[0];
    }

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

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(key.currentContext!,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });
  }

  void _onTypeChanged(String? val) {
    setState(() {
      if (_selectedAccountType != val) {
        if (val == 'Credit Card' ||
            val == 'Cash' ||
            val == 'Wallet' ||
            _selectedAccountType == 'Credit Card' ||
            _selectedAccountType == 'Cash' ||
            _selectedAccountType == 'Wallet') {
          _selectedBank = null;
        }
      }

      _selectedAccountType = val;

      if (val == 'Credit Card') {
        _selectedBank = 'Credit Card Pool Account';
        _accountNoController.text = '****';
        _balanceController.text = '0.0';
      } else if (val == 'Cash') {
        _selectedBank = 'Cash';
        _accountNoController.clear();
      } else if (val == 'Wallet') {
      } else {
        if (_selectedBank == 'Credit Card Pool Account' ||
            _selectedBank == 'Cash') {
          _selectedBank = null;
        }
        if (_accountNoController.text == '****') {
          _accountNoController.clear();
        }
        if (_balanceController.text == '0.0') {
          _balanceController.clear();
        }
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newAccountData = {
          'name': _nameController.text.trim(),
          'bankName': _selectedBank,
          'accountType': _selectedAccountType,
          'accountNumber': _accountNoController.text.trim(),
          'currentBalance':
              double.tryParse(_balanceController.text.replaceAll(',', '')) ??
                  0.0,
          'color': _selectedColor.value,
          'type': 'Bank',
        };

        await widget.onAccountAdded(newAccountData);

        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint("Error adding account: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0D1B2A);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.accountToEdit != null;
    final isCreditCard = _selectedAccountType == 'Credit Card';
    final isCash = _selectedAccountType == 'Cash';
    final isWallet = _selectedAccountType == 'Wallet';

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
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isEditing ? "Edit Account" : "New Account",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 24),

              // 1. Account Name Field with updated constraints
              _buildTextField(
                fieldKey: _nameFieldKey,
                controller: _nameController,
                focusNode: _nameFocus,
                label: isWallet ? "Wallet Name" : "Account Name",
                hint: isCreditCard
                    ? "Credit Card Pool"
                    : (isCash
                        ? "e.g. Wallet / Petty Cash"
                        : (isWallet
                            ? "e.g. Personal PayTM"
                            : "e.g. Personal Savings")),
                icon: isWallet
                    ? Icons.account_balance_wallet
                    : Icons.edit_outlined,
                inputAction: TextInputAction.next,
                maxLength: 20, // Max limit
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (val.trim().length < 2)
                    return 'Minimum 2 characters'; // Min limit
                  return null;
                },
                onSubmitted: () =>
                    FocusScope.of(context).requestFocus(_accNumFocus),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSelectField<String>(
                      label: "Type",
                      value: _selectedAccountType,
                      items: _availableAccountTypes,
                      labelBuilder: (val) => val,
                      onSelect: _onTypeChanged,
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  if (!isCash) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSelectField<String>(
                        label: isWallet ? "Wallet" : "Bank",
                        value: _selectedBank,
                        items: isCreditCard
                            ? ['Credit Card Pool Account']
                            : (isWallet
                                ? BankConstants.wallets
                                : BankConstants.indianBanks),
                        labelBuilder: (val) => val,
                        isEnabled: !isCreditCard,
                        onSelect: (val) => setState(() => _selectedBank = val),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ),
                  ],
                ],
              ),

              if (!isCreditCard && !isCash) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  fieldKey: _accNumFieldKey,
                  controller: _accountNoController,
                  focusNode: _accNumFocus,
                  label: isWallet ? "Phone / ID (Optional)" : "Last 4 Digits",
                  hint: isWallet ? "e.g. 9876543210" : "e.g. 8842",
                  icon: Icons.numbers,
                  inputType: TextInputType.number,
                  maxLength: isWallet ? 15 : 4,
                  isDigitOnly: true,
                  inputAction: TextInputAction.next,
                  onSubmitted: () =>
                      FocusScope.of(context).requestFocus(_balanceFocus),
                ),
              ],

              if (!isCreditCard) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  fieldKey: _balanceFieldKey,
                  controller: _balanceController,
                  focusNode: _balanceFocus,
                  label: isCash ? "Amount on Hand" : "Current Balance",
                  hint: "₹ 0.00",
                  icon: Icons.currency_rupee,
                  inputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputAction: TextInputAction.done,
                  onSubmitted: () => _submit(),
                ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white54, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "This creates a pool account. Individual card details are hidden and balance starts at 0.",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                )
              ],

              const SizedBox(height: 24),
              Text("Card Color",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.5))),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? "Update Account" : "Add Account",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    GlobalKey? fieldKey,
    FocusNode? focusNode,
    TextInputAction? inputAction,
    VoidCallback? onSubmitted,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    bool isDigitOnly = false,
    String? Function(String?)? validator, // Added validator parameter
  }) {
    return Container(
      key: fieldKey,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: inputType,
        textInputAction: inputAction,
        onFieldSubmitted: (_) => onSubmitted?.call(),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        maxLength: maxLength, // Enforces the max character limit
        inputFormatters: isDigitOnly
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxLength)
              ]
            : null,
        validator: validator, // Validation logic
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          prefixIcon:
              Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
          // Character counter styling
          counterStyle:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
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
    bool isEnabled = true,
  }) {
    return FormField<T>(
      validator: validator,
      initialValue: value,
      builder: (FormFieldState<T> state) {
        return Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: isEnabled
                    ? () {
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
                            });
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    errorText: state.errorText,
                    suffixIcon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white54),
                  ),
                  isEmpty: value == null,
                  child: Text(value != null ? labelBuilder(value) : '',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSelectionSheet<T>(
      {required BuildContext context,
      required String title,
      required List<T> items,
      T? selectedItem,
      required String Function(T) labelBuilder,
      required Function(T) onSelect}) {
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(children: [
                const SizedBox(height: 16),
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2)))),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
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
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected
                          ? const Color(0xFF00B4D8).withOpacity(0.2)
                          : Colors.transparent,
                      title: Text(labelBuilder(item),
                          style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00B4D8)
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    );
                  },
                )),
              ]),
            );
          },
        );
      },
    );
  }
}
