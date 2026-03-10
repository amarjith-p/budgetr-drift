import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/database/app_database.dart';
import '../services/vault_auth_service.dart';
import '../services/vault_encryption_service.dart';
import 'secure_text_field.dart';

class AddVaultItemSheet extends StatefulWidget {
  const AddVaultItemSheet({super.key});

  @override
  State<AddVaultItemSheet> createState() => _AddVaultItemSheetState();
}

class _AddVaultItemSheetState extends State<AddVaultItemSheet> {
  bool _isCredential = true; // true = Credential, false = Card

  // Shared
  final _titleController = TextEditingController();

  // Credential
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secPasswordController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();

  // Card
  final _bankController = TextEditingController();
  final _cardNoController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _pinController = TextEditingController();
  final _cardDetailsController = TextEditingController();

  Future<void> _saveData() async {
    if (_titleController.text.trim().isEmpty) return;

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
        'card_no': _cardNoController.text,
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
      onTap: () => setState(() => _isCredential = isTarget),
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
            // Top Handle & Header
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

            // Premium Toggle Bar
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
                      label: "Record Name",
                      icon: Icons.title,
                      hint: "e.g. Netflix, HDFC Bank",
                      isSecureByDefault: false),
                  if (_isCredential) ...[
                    SecureTextField(
                        controller: _usernameController,
                        label: "Username / Email",
                        icon: Icons.person_outline,
                        hint: "Email or User ID"),
                    SecureTextField(
                        controller: _passwordController,
                        label: "Password",
                        icon: Icons.password,
                        hint: "Account Password"),
                    SecureTextField(
                        controller: _secPasswordController,
                        label: "Secondary Password",
                        icon: Icons.lock_outline,
                        hint: "PIN or Backup Password"),
                    SecureTextField(
                        controller: _urlController,
                        label: "URL / App Name",
                        icon: Icons.language,
                        hint: "e.g. netflix.com",
                        isSecureByDefault: false),
                    SecureTextField(
                        controller: _notesController,
                        label: "Notes",
                        icon: Icons.note_alt_outlined,
                        hint: "Any extra details"),
                  ] else ...[
                    SecureTextField(
                        controller: _bankController,
                        label: "Bank / Issuer",
                        icon: Icons.account_balance,
                        hint: "e.g. HDFC",
                        isSecureByDefault: false),
                    SecureTextField(
                        controller: _cardNoController,
                        label: "Card Number",
                        icon: Icons.credit_card,
                        hint: "XXXX XXXX XXXX XXXX",
                        isNumeric: true),
                    Row(
                      children: [
                        Expanded(
                            child: SecureTextField(
                                controller: _expiryController,
                                label: "Expiry",
                                icon: Icons.date_range,
                                hint: "MM/YY")),
                        const SizedBox(width: 12),
                        Expanded(
                            child: SecureTextField(
                                controller: _cvvController,
                                label: "CVV",
                                icon: Icons.security,
                                hint: "123",
                                isNumeric: true)),
                      ],
                    ),
                    SecureTextField(
                        controller: _pinController,
                        label: "PIN",
                        icon: Icons.pin_outlined,
                        hint: "Card PIN",
                        isNumeric: true),
                    SecureTextField(
                        controller: _cardDetailsController,
                        label: "Other Details",
                        icon: Icons.info_outline,
                        hint: "Name on card, etc."),
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
