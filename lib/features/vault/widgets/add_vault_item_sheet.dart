import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/database/app_database.dart';
import '../services/vault_auth_service.dart';
import '../services/vault_encryption_service.dart';
import 'secure_text_field.dart';

// [EXISTING] Formats Expiry as MM/YY
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;
    if (oldValue.text.length > newValue.text.length) return newValue;
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 4) newText = newText.substring(0, 4);
    String formattedText = newText;
    if (newText.length > 2) {
      formattedText = '${newText.substring(0, 2)}/${newText.substring(2)}';
    }
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// [NEW] Formats Card Number as XXXX XXXX XXXX XXXX
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Allow normal backspace behavior
    if (oldValue.text.length > newValue.text.length) return newValue;

    // Remove any existing spaces or non-digit characters
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    // Cap at 19 digits (max length for standard credit cards)
    if (newText.length > 19) newText = newText.substring(0, 19);

    // Insert a space after every 4th character
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write(' ');
      }
    }

    String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class AddVaultItemSheet extends StatefulWidget {
  const AddVaultItemSheet({super.key});

  @override
  State<AddVaultItemSheet> createState() => _AddVaultItemSheetState();
}

class _AddVaultItemSheetState extends State<AddVaultItemSheet> {
  bool _isCredential = true;

  // Field-Specific Error States
  String? _titleError;
  String? _credError;
  String? _cardNoError;

  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secPasswordController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();
  final _bankController = TextEditingController();
  final _cardNoController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _pinController = TextEditingController();
  final _cardDetailsController = TextEditingController();

  final _titleFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _secPasswordFocus = FocusNode();
  final _urlFocus = FocusNode();
  final _notesFocus = FocusNode();
  final _bankFocus = FocusNode();
  final _cardNoFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _cardDetailsFocus = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _secPasswordController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    _bankController.dispose();
    _cardNoController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _cardDetailsController.dispose();

    _titleFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _secPasswordFocus.dispose();
    _urlFocus.dispose();
    _notesFocus.dispose();
    _bankFocus.dispose();
    _cardNoFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _pinFocus.dispose();
    _cardDetailsFocus.dispose();

    super.dispose();
  }

  Future<void> _saveData() async {
    // Reset errors
    setState(() {
      _titleError = null;
      _credError = null;
      _cardNoError = null;
    });

    bool hasError = false;

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = "Record Name is required");
      hasError = true;
      FocusScope.of(context).requestFocus(_titleFocus);
    } else if (_isCredential) {
      if (_usernameController.text.trim().isEmpty &&
          _passwordController.text.trim().isEmpty) {
        setState(() => _credError = "Either Username or Password is required");
        hasError = true;
        FocusScope.of(context).requestFocus(_usernameFocus);
      }
    } else {
      if (_cardNoController.text.trim().isEmpty) {
        setState(() => _cardNoError = "Card Number is required");
        hasError = true;
        FocusScope.of(context).requestFocus(_cardNoFocus);
      }
    }

    if (hasError) return;

    final vaultAuth = locator<VaultAuthService>();
    final encryption = locator<VaultEncryptionService>();
    final db = locator<AppDatabase>();

    if (!vaultAuth.isVaultUnlocked || vaultAuth.activeKey == null) return;

    Map<String, dynamic> payloadMap;
    if (_isCredential) {
      payloadMap = {
        'username': _usernameController.text,
        'password': _passwordController.text,
        'secondary_password': _secPasswordController.text,
        'url': _urlController.text,
        'notes': _notesController.text,
      };
    } else {
      payloadMap = {
        'bank': _bankController.text,
        // [UPDATED] Strip spaces before saving to DB so it's a clean number under the hood
        'card_no': _cardNoController.text.replaceAll(' ', ''),
        'expiry': _expiryController.text,
        'cvv': _cvvController.text,
        'pin': _pinController.text,
        'other_details': _cardDetailsController.text,
      };
    }

    final jsonPayload = jsonEncode(payloadMap);
    final encryptedData =
        encryption.encryptPayload(jsonPayload, vaultAuth.activeKey!);

    await db.into(db.vaultRecords).insert(
          VaultRecordsCompanion.insert(
            id: const Uuid().v4(),
            type: _isCredential ? 'CREDENTIAL' : 'CARD',
            title: _titleController.text.trim(),
            encryptedPayload: encryptedData['payload']!,
            iv: encryptedData['iv']!,
          ),
        );

    if (mounted) Navigator.pop(context, true);
  }

  Widget _buildToggle(String label, bool isTarget) {
    final isSelected = _isCredential == isTarget;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCredential = isTarget;
          _titleError = null;
          _credError = null;
          _cardNoError = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BudgetrColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: BudgetrColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text(
              "SECURE ENTRY",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildToggle("CREDENTIALS", true)),
                  Expanded(child: _buildToggle("CARD DETAILS", false)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SecureTextField(
                      controller: _titleController,
                      focusNode: _titleFocus,
                      errorText: _titleError,
                      onChanged: (_) => setState(() => _titleError = null),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => FocusScope.of(context).requestFocus(
                          _isCredential ? _usernameFocus : _bankFocus),
                      label: "Record Name",
                      icon: Icons.title,
                      hint: "e.g. Netflix, HDFC Bank",
                      isSecureByDefault: false),
                  if (_isCredential) ...[
                    SecureTextField(
                        key: const ValueKey('cred_user'),
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        errorText: _credError,
                        onChanged: (_) => setState(() => _credError = null),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                        label: "Username",
                        icon: Icons.person_outline,
                        hint: "Username or Email",
                        isSecureByDefault: true),
                    SecureTextField(
                        key: const ValueKey('cred_pass'),
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        errorText: _credError,
                        onChanged: (_) => setState(() => _credError = null),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_secPasswordFocus),
                        label: "Password",
                        icon: Icons.password,
                        hint: "Account Password",
                        isSecureByDefault: true),
                    SecureTextField(
                        key: const ValueKey('cred_sec_pass'),
                        controller: _secPasswordController,
                        focusNode: _secPasswordFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_urlFocus),
                        label: "Secondary Password",
                        icon: Icons.lock_outline,
                        hint: "Transaction / Profile Passwords",
                        isSecureByDefault: true),
                    SecureTextField(
                        key: const ValueKey('cred_url'),
                        controller: _urlController,
                        focusNode: _urlFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_notesFocus),
                        label: "URL / App Name",
                        icon: Icons.language,
                        hint: "e.g. hdfc.bank.in",
                        isSecureByDefault: true),
                    SecureTextField(
                        key: const ValueKey('cred_notes'),
                        controller: _notesController,
                        focusNode: _notesFocus,
                        textInputAction: TextInputAction.done,
                        label: "Notes",
                        icon: Icons.note_alt_outlined,
                        hint: "Any extra details",
                        isSecureByDefault: true),
                  ] else ...[
                    SecureTextField(
                        key: const ValueKey('card_bank'),
                        controller: _bankController,
                        focusNode: _bankFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_cardNoFocus),
                        label: "Bank / Issuer",
                        icon: Icons.account_balance,
                        hint: "e.g. HDFC Bank",
                        isSecureByDefault: false),
                    SecureTextField(
                        key: const ValueKey('card_no'),
                        controller: _cardNoController,
                        focusNode: _cardNoFocus,
                        errorText: _cardNoError,
                        onChanged: (_) => setState(() => _cardNoError = null),
                        textInputAction: TextInputAction.next,
                        // [NEW] Added CardNumberFormatter here
                        inputFormatters: [CardNumberFormatter()],
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_expiryFocus),
                        label: "Card Number",
                        icon: Icons.credit_card,
                        hint: "XXXX XXXX XXXX XXXX",
                        isNumeric: true,
                        isSecureByDefault: true),
                    Row(
                      children: [
                        Expanded(
                            child: SecureTextField(
                                key: const ValueKey('card_exp'),
                                controller: _expiryController,
                                focusNode: _expiryFocus,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [ExpiryDateFormatter()],
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_cvvFocus),
                                label: "Expiry",
                                icon: Icons.date_range,
                                hint: "MM/YY",
                                isNumeric: true,
                                isSecureByDefault: true)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: SecureTextField(
                                key: const ValueKey('card_cvv'),
                                controller: _cvvController,
                                focusNode: _cvvFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_pinFocus),
                                label: "CVV",
                                icon: Icons.security,
                                hint: "123",
                                isNumeric: true,
                                isSecureByDefault: true)),
                      ],
                    ),
                    SecureTextField(
                        key: const ValueKey('card_pin'),
                        controller: _pinController,
                        focusNode: _pinFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_cardDetailsFocus),
                        label: "PIN",
                        icon: Icons.pin_outlined,
                        hint: "Card PIN",
                        isNumeric: true,
                        isSecureByDefault: true),
                    SecureTextField(
                        key: const ValueKey('card_details'),
                        controller: _cardDetailsController,
                        focusNode: _cardDetailsFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _saveData(),
                        label: "Other Details",
                        icon: Icons.info_outline,
                        hint: "Name on card, etc.",
                        isSecureByDefault: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetrColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: BudgetrColors.accent.withOpacity(0.4),
                ),
                onPressed: _saveData,
                child: const Text("ENCRYPT & SAVE",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
