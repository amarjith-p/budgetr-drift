import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class VaultEncryptionService {
  /// Generates a highly secure 256-bit (32 byte) random Master Vault Key
  enc.Key generateVaultKey() {
    return enc.Key.fromSecureRandom(32);
  }

  /// Stretches the user's password into a 32-byte Key Encryption Key (KEK)
  /// using 10,000 rounds of SHA-256 to prevent brute-force attacks.
  enc.Key deriveKeyFromPassword(String password, String salt) {
    // FIXED: Explicitly declared as List<int> to prevent assignment errors
    List<int> bytes = utf8.encode(password + salt);
    for (int i = 0; i < 10000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return enc.Key(Uint8List.fromList(bytes));
  }

  /// Encrypts the Vault Key so it can be saved in SharedPreferences
  String encryptVaultKey(enc.Key vaultKey, enc.Key kek, enc.IV iv) {
    final encrypter = enc.Encrypter(enc.AES(kek, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encryptBytes(vaultKey.bytes, iv: iv);
    return encrypted.base64;
  }

  /// Decrypts the Vault Key using the Master Password KEK
  enc.Key decryptVaultKey(String encryptedBase64, enc.Key kek, enc.IV iv) {
    final encrypter = enc.Encrypter(enc.AES(kek, mode: enc.AESMode.gcm));
    final decryptedBytes = encrypter
        .decryptBytes(enc.Encrypted.fromBase64(encryptedBase64), iv: iv);
    return enc.Key(Uint8List.fromList(decryptedBytes));
  }

  /// Encrypts the actual user data (Cards, Passwords) before DB insertion
  Map<String, String> encryptPayload(String jsonPayload, enc.Key vaultKey) {
    final iv = enc.IV.fromSecureRandom(16); // Unique IV per record
    final encrypter = enc.Encrypter(enc.AES(vaultKey, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(jsonPayload, iv: iv);

    return {
      'payload': encrypted.base64,
      'iv': iv.base64,
    };
  }

  /// Decrypts the user data to show on the Dashboard
  String decryptPayload(
      String encryptedBase64, String ivBase64, enc.Key vaultKey) {
    final iv = enc.IV.fromBase64(ivBase64);
    final encrypter = enc.Encrypter(enc.AES(vaultKey, mode: enc.AESMode.gcm));
    return encrypter.decrypt(enc.Encrypted.fromBase64(encryptedBase64), iv: iv);
  }
}
