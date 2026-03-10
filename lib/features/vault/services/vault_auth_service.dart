import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:local_auth/local_auth.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../core/services/service_locator.dart'; // [NEW] Needed for database access
import '../../../core/database/app_database.dart'; // [NEW] Needed for database access
import 'vault_encryption_service.dart';

class VaultAuthService {
  final VaultEncryptionService _crypto = VaultEncryptionService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  enc.Key? _activeVaultKey;

  bool get isVaultUnlocked => _activeVaultKey != null;
  enc.Key? get activeKey => _activeVaultKey;

  bool pauseAutoLock = false;

  void lockVault() {
    _activeVaultKey = null;
  }

  // --- SCREENSHOT PROTECTION ---
  Future<void> enableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      // Ignore if running on an unsupported platform (e.g. desktop)
    }
  }

  Future<void> disableSecureMode() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      // Ignore
    }
  }

  // --- CORE AUTH LOGIC ---
  Future<bool> isVaultConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('vault_salt');
  }

  Future<void> setupVault(String masterPassword, bool enableBiometrics) async {
    final prefs = await SharedPreferences.getInstance();

    final salt = enc.Key.fromSecureRandom(16).base64;
    final iv = enc.IV.fromSecureRandom(16);

    final vaultKey = _crypto.generateVaultKey();

    final kek = _crypto.deriveKeyFromPassword(masterPassword, salt);
    final encryptedVaultKey = _crypto.encryptVaultKey(vaultKey, kek, iv);

    await prefs.setString('vault_salt', salt);
    await prefs.setString('vault_iv', iv.base64);
    await prefs.setString('vault_encrypted_key', encryptedVaultKey);
    await prefs.setBool('vault_biometrics_enabled', enableBiometrics);
    await resetFailedAttempts(); // [NEW] Ensure attempts are 0 on fresh setup

    if (enableBiometrics) {
      await _secureStorage.write(key: 'vault_raw_key', value: vaultKey.base64);
    } else {
      await _secureStorage.delete(key: 'vault_raw_key');
    }

    _activeVaultKey = vaultKey;
  }

  Future<bool> unlockWithPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = prefs.getString('vault_salt')!;
      final ivBase64 = prefs.getString('vault_iv')!;
      final encryptedKey = prefs.getString('vault_encrypted_key')!;

      final kek = _crypto.deriveKeyFromPassword(password, salt);
      final iv = enc.IV.fromBase64(ivBase64);

      _activeVaultKey = _crypto.decryptVaultKey(encryptedKey, kek, iv);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlockWithBiometrics() async {
    try {
      final rawKeyBase64 = await _secureStorage.read(key: 'vault_raw_key');
      if (rawKeyBase64 != null) {
        pauseAutoLock = true;
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Scan Fingerprint/Face to Unlock Vault',
          options: const AuthenticationOptions(
              stickyAuth: true, biometricOnly: false),
        );
        pauseAutoLock = false;

        if (didAuthenticate) {
          _activeVaultKey = enc.Key.fromBase64(rawKeyBase64);
          await resetFailedAttempts(); // [NEW] Reset attempts on successful biometric unlock
          return true;
        }
      }
      return false;
    } catch (e) {
      pauseAutoLock = false;
      return false;
    }
  }

  // --- SECURITY ENFORCEMENT LOGIC [NEW] ---
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vault_failed_attempts') ?? 0;
  }

  Future<void> incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('vault_failed_attempts') ?? 0;
    await prefs.setInt('vault_failed_attempts', current + 1);
  }

  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vault_failed_attempts');
  }

  Future<void> wipeVault() async {
    // 1. Clear SharedPreferences Auth Data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vault_salt');
    await prefs.remove('vault_iv');
    await prefs.remove('vault_encrypted_key');
    await prefs.remove('vault_biometrics_enabled');
    await prefs.remove('vault_failed_attempts');

    // 2. Clear Secure Storage
    await _secureStorage.delete(key: 'vault_raw_key');

    // 3. Clear Active Session
    _activeVaultKey = null;

    // 4. Wipe Drift Database Records
    final db = locator<AppDatabase>();
    await db.delete(db.vaultRecords).go();
  }

  // --- SETTINGS LOGIC ---
  Future<bool> authenticateBiometrics(String reason) async {
    try {
      pauseAutoLock = true;
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options:
            const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      pauseAutoLock = false;
      return result;
    } catch (e) {
      pauseAutoLock = false;
      return false;
    }
  }

  Future<bool> getBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vault_biometrics_enabled') ?? false;
  }

  Future<void> toggleBiometrics(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vault_biometrics_enabled', enable);

    if (enable && _activeVaultKey != null) {
      await _secureStorage.write(
          key: 'vault_raw_key', value: _activeVaultKey!.base64);
    } else {
      await _secureStorage.delete(key: 'vault_raw_key');
    }
  }

  Future<bool> changeMasterPassword(
      String currentPassword, String newPassword) async {
    if (_activeVaultKey == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final oldSalt = prefs.getString('vault_salt')!;
    final oldIvBase64 = prefs.getString('vault_iv')!;
    final oldEncryptedKey = prefs.getString('vault_encrypted_key')!;

    try {
      final oldKek = _crypto.deriveKeyFromPassword(currentPassword, oldSalt);
      final oldIv = enc.IV.fromBase64(oldIvBase64);
      _crypto.decryptVaultKey(oldEncryptedKey, oldKek, oldIv);
    } catch (e) {
      return false;
    }

    final newSalt = enc.Key.fromSecureRandom(16).base64;
    final newIv = enc.IV.fromSecureRandom(16);
    final newKek = _crypto.deriveKeyFromPassword(newPassword, newSalt);
    final newEncryptedVaultKey =
        _crypto.encryptVaultKey(_activeVaultKey!, newKek, newIv);

    await prefs.setString('vault_salt', newSalt);
    await prefs.setString('vault_iv', newIv.base64);
    await prefs.setString('vault_encrypted_key', newEncryptedVaultKey);

    return true;
  }
}
