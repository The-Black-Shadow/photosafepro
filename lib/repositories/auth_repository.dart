import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthRepository {
  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  static const _pinKey = 'user_pin_hash';

  // Hashes the PIN using SHA-256.
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin); // data being hashed
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Saves the hashed PIN to secure storage.
  Future<void> setPin(String pin) async {
    final hashedPin = _hashPin(pin);
    await _secureStorage.write(key: _pinKey, value: hashedPin);
  }

  // Verifies the entered PIN against the stored hash.
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    if (storedHash == null) {
      return false; // No PIN is set
    }
    final hashedPin = _hashPin(pin);
    return hashedPin == storedHash;
  }

  // Checks if a PIN has already been set.
  Future<bool> hasPin() async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    return storedHash != null;
  }

  // Deletes the PIN from secure storage.
  Future<void> deletePin() async {
    await _secureStorage.delete(key: _pinKey);
  }
  // --- Biometric Methods ---

  /// Checks if biometric authentication is available on the device.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      debugPrint("[AuthRepo] Can check biometrics: $canCheckBiometrics");
      debugPrint("[AuthRepo] Is device supported: $isDeviceSupported");

      if (canCheckBiometrics && isDeviceSupported) {
        // Check if there are any biometrics enrolled
        final List<BiometricType> availableBiometrics = await _localAuth
            .getAvailableBiometrics();
        debugPrint("[AuthRepo] Available biometrics: $availableBiometrics");
        return availableBiometrics.isNotEmpty;
      }

      return false;
    } on PlatformException catch (e) {
      debugPrint("[AuthRepo] Platform exception: ${e.toString()}");
      return false;
    } catch (e) {
      debugPrint("[AuthRepo] General exception: ${e.toString()}");
      return false;
    }
  }

  /// Triggers the biometric authentication prompt.
  Future<bool> authenticateWithBiometrics() async {
    try {
      debugPrint("[AuthRepo] Starting biometric authentication");

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your vault',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the prompt open until success/failure
          biometricOnly: true, // Only allow biometrics, not device PIN
        ),
      );

      debugPrint(
        "[AuthRepo] Biometric authentication result: $didAuthenticate",
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint(
        "[AuthRepo] Platform exception during biometric auth: ${e.toString()}",
      );
      debugPrint("[AuthRepo] Error code: ${e.code}");
      debugPrint("[AuthRepo] Error message: ${e.message}");
      return false;
    } catch (e) {
      debugPrint(
        "[AuthRepo] General exception during biometric auth: ${e.toString()}",
      );
      return false;
    }
  }
}
