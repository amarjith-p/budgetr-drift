import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../../../core/services/service_locator.dart';
import '../services/vault_auth_service.dart';
import 'vault_dashboard_screen.dart';

class VaultAuthScreen extends StatefulWidget {
  const VaultAuthScreen({super.key});

  @override
  State<VaultAuthScreen> createState() => _VaultAuthScreenState();
}

class _VaultAuthScreenState extends State<VaultAuthScreen>
    with SingleTickerProviderStateMixin {
  final _auth = locator<VaultAuthService>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = true;
  bool _isConfigured = false;
  bool _setupEnableBiometrics = true;
  bool _savedBiometricsEnabled = false;
  String _errorMessage = "";

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // [FIX] Ensure the screen is built before locking the OS
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _auth.enableSecureMode();
    });

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _checkStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final configured = await _auth.isVaultConfigured();
    final biometricsOn = await _auth.getBiometricsEnabled();

    setState(() {
      _isConfigured = configured;
      _savedBiometricsEnabled = biometricsOn;
      _isLoading = false;
    });

    _animController.forward();

    if (configured && biometricsOn) {
      await Future.delayed(const Duration(milliseconds: 400));
      _tryBiometricUnlock();
    }
  }

  Future<void> _tryBiometricUnlock() async {
    final success = await _auth.unlockWithBiometrics();
    if (success && mounted) _navigateToDashboard();
  }

  Future<void> _handleSetup() async {
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters.");
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);
    await _auth.setupVault(_passwordController.text, _setupEnableBiometrics);
    if (mounted) _navigateToDashboard();
  }

  Future<void> _handleUnlock() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final success = await _auth.unlockWithPassword(_passwordController.text);

    if (success && mounted) {
      _navigateToDashboard();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Incorrect Master Password.";
      });
    }
  }

  void _navigateToDashboard() {
    // Note: We DO NOT turn off secure mode here because we want it active in the Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VaultDashboardScreen()),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon:
            Icon(icon, color: BudgetrColors.accent.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: BudgetrColors.accent.withOpacity(0.6), width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          backgroundColor: BudgetrColors.background,
          body: const Center(
              child: FuturisticLoader(label: "AUTHENTICATING...")));
    }

    // [NEW] WillPopScope handles physical back buttons
    return WillPopScope(
      onWillPop: () async {
        await _auth.disableSecureMode(); // Unblock screenshots on exit
        return true;
      },
      child: Scaffold(
        backgroundColor: BudgetrColors.background,
        body: Stack(
          children: [
            Positioned(
                top: -100,
                right: -100,
                child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BudgetrColors.accent.withOpacity(0.12)))),
            Positioned(
                bottom: -150,
                left: -100,
                child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E676).withOpacity(0.08)))),
            Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: const SizedBox())),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70),
                onPressed: () async {
                  await _auth
                      .disableSecureMode(); // Unblock screenshots on UI back press
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1B263B).withOpacity(0.5),
                              border: Border.all(
                                  color: BudgetrColors.accent.withOpacity(0.3),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        BudgetrColors.accent.withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 5)
                              ]),
                          child: Icon(Icons.security_rounded,
                              size: 64, color: BudgetrColors.accent),
                        ),
                        const SizedBox(height: 24),
                        Text(_isConfigured ? "SECURE VAULT" : "VAULT SETUP",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0)),
                        const SizedBox(height: 8),
                        Text(
                            _isConfigured
                                ? "Enter your Master Password to decrypt data."
                                : "Create a Master Password to encrypt your data.",
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: const Color(0xFF1B263B).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10))
                              ]),
                          child: Column(
                            children: [
                              _buildTextField(
                                  _passwordController,
                                  _isConfigured
                                      ? "Master Password"
                                      : "Create Master Password",
                                  Icons.vpn_key_rounded),
                              if (!_isConfigured) ...[
                                const SizedBox(height: 16),
                                _buildTextField(
                                    _confirmController,
                                    "Confirm Password",
                                    Icons.lock_outline_rounded),
                                const SizedBox(height: 16),
                                Theme(
                                  data: ThemeData(
                                      unselectedWidgetColor: Colors.white54),
                                  child: CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text("Enable Biometric Unlock",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                    value: _setupEnableBiometrics,
                                    activeColor: BudgetrColors.accent,
                                    checkColor: Colors.white,
                                    onChanged: (val) => setState(() =>
                                        _setupEnableBiometrics = val ?? true),
                                  ),
                                ),
                              ],
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(_errorMessage,
                                        style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 13),
                                        textAlign: TextAlign.center)),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: BudgetrColors.accent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 5,
                                    shadowColor:
                                        BudgetrColors.accent.withOpacity(0.5),
                                  ),
                                  onPressed: _isConfigured
                                      ? _handleUnlock
                                      : _handleSetup,
                                  child: Text(
                                      _isConfigured
                                          ? "UNLOCK VAULT"
                                          : "INITIALIZE STORAGE",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5)),
                                ),
                              ),
                              if (_isConfigured && _savedBiometricsEnabled) ...[
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _tryBiometricUnlock,
                                  icon: Icon(Icons.fingerprint_rounded,
                                      color: BudgetrColors.accent, size: 24),
                                  label: Text("Use Biometrics",
                                      style: TextStyle(
                                          color: BudgetrColors.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                )
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
