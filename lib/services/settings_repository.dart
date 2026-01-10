import '../api/api_service_factory.dart';
import '../models/settings.dart';
import 'secure_storage_service.dart';
import 'biometric_service.dart';
import 'permission_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings Repository
/// 
/// Handles all settings-related business logic including:
/// - Fetching/updating settings from API
/// - Biometric authentication management
/// - Two-factor authentication flows
/// - Push notification permission handling
class SettingsRepository {
  final _apiService = ApiServiceFactory.getService();
  final _secureStorage = SecureStorageService();
  final _biometricService = BiometricService();
  final _permissionService = PermissionService();

  /// Get app version from package info
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0'; // Fallback version
    }
  }

  /// Fetch settings from API
  Future<Settings> fetchSettings() async {
    final appVersion = await getAppVersion();
    final response = await _apiService.getSettings();

    if (response.success && response.data != null) {
      // Also check local secure storage for biometric flag
      final localBiometricEnabled = await _secureStorage.getBiometricEnabled();
      
      return Settings.fromJson(response.data!, appVersion).copyWith(
        biometricEnabled: localBiometricEnabled || response.data!['biometricEnabled'] == true,
      );
    }

    // Return default settings on error
    return Settings(appVersion: appVersion);
  }

  /// Update settings (partial update supported)
  Future<bool> updateSettings(Map<String, dynamic> updates) async {
    final response = await _apiService.updateSettings(updates);
    return response.success;
  }

  /// Enable biometric authentication
  /// Returns error message if failed, null if success
  Future<String?> enableBiometric() async {
    try {
      // 1. Check device capability
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        return 'Biometric authentication is not available on this device. Please set up Face ID, Touch ID, or fingerprint in your device settings.';
      }

      // 2. Check if biometric is enrolled
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return 'No biometric authentication method is enrolled on this device. Please set up Face ID, Touch ID, or fingerprint in your device settings.';
      }

      // 3. Prompt user for biometric authentication
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Enable biometric authentication for secure access',
      );

      if (!authenticated) {
        return 'Biometric authentication failed or was cancelled.';
      }

      // 4. Save to secure storage
      await _secureStorage.setBiometricEnabled(true);

      // 5. Update API
      final success = await updateSettings({'biometricEnabled': true});
      if (!success) {
        // Revert local storage if API fails
        await _secureStorage.clearBiometricEnabled();
        return 'Failed to enable biometric authentication. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred while enabling biometric authentication: ${e.toString()}';
    }
  }

  /// Disable biometric authentication
  /// Requires re-authentication
  Future<String?> disableBiometric() async {
    try {
      // 1. Require re-authentication
      // Try biometric first, if available
      final biometricAvailable = await _biometricService.isAvailable();
      bool authenticated = false;

      if (biometricAvailable) {
        authenticated = await _biometricService.authenticate(
          localizedReason: 'Disable biometric authentication',
        );
      }

      if (!authenticated) {
        return 'Authentication required to disable biometric authentication.';
      }

      // 2. Clear from secure storage
      await _secureStorage.clearBiometricEnabled();

      // 3. Update API
      final success = await updateSettings({'biometricEnabled': false});
      if (!success) {
        // Restore local storage if API fails
        await _secureStorage.setBiometricEnabled(true);
        return 'Failed to disable biometric authentication. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred while disabling biometric authentication: ${e.toString()}';
    }
  }

  /// Enable two-factor authentication
  /// Returns (error message, challengeId if enrollment started)
  Future<({String? error, String? challengeId})> enableTwoFactor() async {
    try {
      final response = await _apiService.enrollTwoFactor();

      if (!response.success) {
        return (
          error: (response.message ?? 'Failed to start 2FA enrollment') as String?,
          challengeId: null,
        );
      }

      if (response.data == null) {
        return (error: 'Invalid response from server', challengeId: null);
      }

      final enrollResponse = TwoFactorEnrollResponse.fromJson(response.data!);
      return (error: null, challengeId: enrollResponse.challengeId);
    } catch (e) {
      return (error: 'An error occurred: ${e.toString()}', challengeId: null);
    }
  }

  /// Verify two-factor authentication code
  Future<String?> verifyTwoFactor(String challengeId, String code) async {
    try {
      final response = await _apiService.verifyTwoFactor(challengeId, code);

      if (!response.success) {
        return response.message ?? 'Invalid verification code. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  /// Disable two-factor authentication
  /// Requires re-authentication (password or biometric)
  Future<String?> disableTwoFactor({String? password}) async {
    try {
      // If biometric is enabled, use it; otherwise require password
      final biometricEnabled = await _secureStorage.getBiometricEnabled();
      
      if (biometricEnabled) {
        final authenticated = await _biometricService.authenticate(
          localizedReason: 'Disable two-factor authentication',
        );
        if (!authenticated) {
          return 'Authentication required to disable two-factor authentication.';
        }
      } else if (password == null || password.isEmpty) {
        return 'Password is required to disable two-factor authentication.';
      }

      final response = await _apiService.disableTwoFactor(password);
      if (!response.success) {
        return response.message ?? 'Failed to disable two-factor authentication. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  /// Enable push notifications
  /// Returns error message if failed, null if success
  Future<String?> enablePushNotifications() async {
    try {
      // 1. Check/request permission
      final isGranted = await _permissionService.isNotificationPermissionGranted();
      
      if (!isGranted) {
        final requested = await _permissionService.requestNotificationPermission();
        if (!requested) {
          final isPermanentlyDenied = await _permissionService.isNotificationPermissionPermanentlyDenied();
          if (isPermanentlyDenied) {
            return 'PERMANENTLY_DENIED'; // Special flag for UI to show "Open Settings"
          }
          return 'Push notification permission was denied. Please enable it in Settings.';
        }
      }

      // 2. Update API
      final success = await updateSettings({'pushEnabled': true});
      if (!success) {
        return 'Failed to enable push notifications. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  /// Disable push notifications
  Future<String?> disablePushNotifications() async {
    try {
      final success = await updateSettings({'pushEnabled': false});
      if (!success) {
        return 'Failed to disable push notifications. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  /// Enable email notifications
  Future<String?> enableEmailNotifications() async {
    try {
      final success = await updateSettings({'emailEnabled': true});
      if (!success) {
        return 'Failed to enable email notifications. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  /// Disable email notifications
  Future<String?> disableEmailNotifications() async {
    try {
      final success = await updateSettings({'emailEnabled': false});
      if (!success) {
        return 'Failed to disable email notifications. Please try again.';
      }

      return null; // Success
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }
}

