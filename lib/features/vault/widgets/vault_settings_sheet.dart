import 'package:flutter/material.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/service_locator.dart';
import '../services/vault_auth_service.dart';
import 'secure_text_field.dart';

class VaultSettingsSheet extends StatefulWidget {
  const VaultSettingsSheet({super.key});

  @override
  State<VaultSettingsSheet> createState() => _VaultSettingsSheetState();
}

class _VaultSettingsSheetState extends State<VaultSettingsSheet> {
  final _auth = locator<VaultAuthService>();

  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  bool _biometricsEnabled = false;
  bool _isLoading = false;
  String _message = "";
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _auth.getBiometricsEnabled();
    setState(() {
      _biometricsEnabled = enabled;
    });
  }

  Future<void> _handleToggleBiometrics(bool val) async {
    final verified = await _auth.authenticateBiometrics(val
        ? "Verify identity to enable Biometrics"
        : "Verify identity to disable Biometrics");

    if (verified) {
      setState(() => _biometricsEnabled = val);
      await _auth.toggleBiometrics(val);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(val
                ? "Biometric Unlock Enabled"
                : "Biometric Unlock Disabled")));
        // [FIX] Close the settings sheet automatically so the user isn't confused
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleChangePassword() async {
    if (_currentPwdController.text == _newPwdController.text) {
      setState(() {
        _message = "New password must be different from current password.";
        _isError = true;
      });
      return;
    }
    if (_newPwdController.text.length < 6) {
      setState(() {
        _message = "New password must be at least 6 characters.";
        _isError = true;
      });
      return;
    }
    if (_newPwdController.text != _confirmPwdController.text) {
      setState(() {
        _message = "New passwords do not match.";
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    final success = await _auth.changeMasterPassword(
        _currentPwdController.text, _newPwdController.text);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Master Password Updated Successfully")));
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        _message = "Incorrect Current Password.";
        _isError = true;
      });
    }
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
              "VAULT SECURITY SETTINGS",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 20),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: BudgetrColors.accent,
                title: const Text("Biometric Unlock",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                subtitle: Text("Use Fingerprint/FaceID to enter vault",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                value: _biometricsEnabled,
                onChanged: _handleToggleBiometrics,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "CHANGE MASTER PASSWORD",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SecureTextField(
                      controller: _currentPwdController,
                      label: "Current Password",
                      icon: Icons.vpn_key_rounded,
                      hint: "Enter old password"),
                  SecureTextField(
                      controller: _newPwdController,
                      label: "New Password",
                      icon: Icons.lock_outline_rounded,
                      hint: "Enter new password"),
                  SecureTextField(
                      controller: _confirmPwdController,
                      label: "Confirm New",
                      icon: Icons.lock_outline_rounded,
                      hint: "Re-enter new password"),
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(_message,
                          style: TextStyle(
                              color: _isError
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BudgetrColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _handleChangePassword,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("UPDATE PASSWORD",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
