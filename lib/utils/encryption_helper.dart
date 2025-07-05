import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  final _secureStorage = const FlutterSecureStorage();
  static const _keyStorageKey = 'encryption_key';

  Future<encrypt.Key> _getOrCreateKey() async {
    String? base64Key = await _secureStorage.read(key: _keyStorageKey);
    if (base64Key == null) {
      final key = encrypt.Key.fromSecureRandom(32); // AES-256
      await _secureStorage.write(key: _keyStorageKey, value: key.base64);
      return key;
    }
    return encrypt.Key.fromBase64(base64Key);
  }

  Future<encrypt.Encrypter> _getEncrypter() async {
    final key = await _getOrCreateKey();
    return encrypt.Encrypter(encrypt.AES(key));
  }

  /// Encrypts bytes and returns a combined Base64 string of "IV:data".
  Future<String> encryptBytes(List<int> bytes) async {
    final encrypter = await _getEncrypter();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    // Combine IV and encrypted data into a single string for storage.
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a combined "IV:data" string back to bytes.
  Future<List<int>> decryptString(String encryptedString) async {
    final encrypter = await _getEncrypter();
    final parts = encryptedString.split(':');

    if (parts.length != 2) {
      throw Exception(
        "Invalid encrypted data format. Could not find IV separator.",
      );
    }

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

    return encrypter.decryptBytes(encrypted, iv: iv);
  }
}
