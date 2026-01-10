import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service
/// 
/// Handles secure storage of sensitive data like biometric flags and PINs
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinKey = 'user_pin';

  /// Save biometric enabled flag
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Get biometric enabled flag
  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Clear biometric enabled flag
  Future<void> clearBiometricEnabled() async {
    await _storage.delete(key: _biometricEnabledKey);
  }

  /// Save user PIN (hashed in production)
  Future<void> savePin(String pin) async {
    // TODO: Hash PIN before storing in production
    await _storage.write(key: _pinKey, value: pin);
  }

  /// Get stored PIN
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Check if PIN exists
  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  /// Clear stored PIN
  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  /// Clear all secure storage (for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

