import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import '../services/settings_repository.dart';

/// Settings Provider
/// 
/// Manages settings state using ChangeNotifier pattern
class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();
  
  Settings _settings = Settings(appVersion: '1.0.0');
  bool _isInitialized = false;

  Settings get settings => _settings;
  bool get isInitialized => _isInitialized;

  /// Initialize settings (fetch from API)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _settings = _settings.copyWith(isLoadingInitial: true);
    notifyListeners();

    try {
      _settings = await _repository.fetchSettings();
      _isInitialized = true;
    } catch (e) {
      _settings = _settings.copyWith(
        lastError: 'Failed to load settings: ${e.toString()}',
      );
    } finally {
      _settings = _settings.copyWith(isLoadingInitial: false);
      notifyListeners();
    }
  }

  /// Set loading state for a specific toggle
  void _setToggleLoading(String toggleName, bool loading) {
    final updated = Map<String, bool>.from(_settings.perToggleLoading);
    if (loading) {
      updated[toggleName] = true;
    } else {
      updated.remove(toggleName);
    }
    _settings = _settings.copyWith(
      perToggleLoading: updated,
      lastError: null,
    );
    notifyListeners();
  }

  /// Check if a specific toggle is loading
  bool isToggleLoading(String toggleName) {
    return _settings.perToggleLoading[toggleName] ?? false;
  }

  /// Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    // Optimistically update UI
    _settings = _settings.copyWith(biometricEnabled: enabled);
    _setToggleLoading('biometric', true);
    notifyListeners();

    try {
      String? error;
      if (enabled) {
        error = await _repository.enableBiometric();
        if (error != null) {
          // Revert on error
          _settings = _settings.copyWith(biometricEnabled: false);
        } else {
          // Confirm it's enabled
          _settings = _settings.copyWith(biometricEnabled: true);
        }
      } else {
        error = await _repository.disableBiometric();
        if (error != null) {
          // Revert on error
          _settings = _settings.copyWith(biometricEnabled: true);
        } else {
          // Confirm it's disabled
          _settings = _settings.copyWith(biometricEnabled: false);
        }
      }

      _settings = _settings.copyWith(lastError: error);
    } catch (e) {
      // Revert on exception
      _settings = _settings.copyWith(
        biometricEnabled: !enabled,
        lastError: 'An error occurred: ${e.toString()}',
      );
    } finally {
      _setToggleLoading('biometric', false);
    }
  }

  /// Toggle two-factor authentication
  /// Returns challengeId if enrollment started (for verification screen)
  Future<String?> toggleTwoFactor(bool enabled) async {
    _setToggleLoading('twoFactor', true);
    notifyListeners();

    try {
      if (enabled) {
        final result = await _repository.enableTwoFactor();
        _setToggleLoading('twoFactor', false);

        if (result.error != null) {
          _settings = _settings.copyWith(lastError: result.error);
          notifyListeners();
          return null;
        }

        // Return challengeId for verification
        return result.challengeId;
      } else {
        final error = await _repository.disableTwoFactor();
        _setToggleLoading('twoFactor', false);

        if (error != null) {
          _settings = _settings.copyWith(
            lastError: error,
            twoFactorEnabled: true, // Keep enabled on error
          );
          notifyListeners();
          return null;
        }

        _settings = _settings.copyWith(twoFactorEnabled: false);
        notifyListeners();
        return null;
      }
    } catch (e) {
      _setToggleLoading('twoFactor', false);
      _settings = _settings.copyWith(
        lastError: 'An error occurred: ${e.toString()}',
      );
      notifyListeners();
      return null;
    }
  }

  /// Verify two-factor authentication code
  Future<bool> verifyTwoFactor(String challengeId, String code) async {
    _setToggleLoading('twoFactor', true);
    notifyListeners();

    try {
      final error = await _repository.verifyTwoFactor(challengeId, code);
      _setToggleLoading('twoFactor', false);

      if (error != null) {
        _settings = _settings.copyWith(lastError: error);
        notifyListeners();
        return false;
      }

      _settings = _settings.copyWith(twoFactorEnabled: true);
      notifyListeners();
      return true;
    } catch (e) {
      _setToggleLoading('twoFactor', false);
      _settings = _settings.copyWith(
        lastError: 'An error occurred: ${e.toString()}',
      );
      notifyListeners();
      return false;
    }
  }

  /// Toggle push notifications
  Future<void> togglePushNotifications(bool enabled) async {
    // Optimistically update UI
    _settings = _settings.copyWith(pushEnabled: enabled);
    _setToggleLoading('push', true);
    notifyListeners();

    try {
      String? error;
      if (enabled) {
        error = await _repository.enablePushNotifications();
        if (error != null) {
          // Revert on error
          _settings = _settings.copyWith(pushEnabled: false);
        }
      } else {
        error = await _repository.disablePushNotifications();
        if (error != null) {
          // Revert on error
          _settings = _settings.copyWith(pushEnabled: true);
        }
      }

      _settings = _settings.copyWith(lastError: error);
    } catch (e) {
      // Revert on exception
      _settings = _settings.copyWith(
        pushEnabled: !enabled,
        lastError: 'An error occurred: ${e.toString()}',
      );
    } finally {
      _setToggleLoading('push', false);
    }
  }

  /// Toggle email notifications
  Future<void> toggleEmailNotifications(bool enabled) async {
    // Optimistically update UI
    _settings = _settings.copyWith(emailEnabled: enabled);
    _setToggleLoading('email', true);
    notifyListeners();

    try {
      String? error;
      if (enabled) {
        error = await _repository.enableEmailNotifications();
        if (error != null) {
          // Revert on error
          _settings = _settings.copyWith(emailEnabled: false);
        }
      } else {
        error = await _repository.disableEmailNotifications();
        if (error != null) {
          // Revert on error
          _settings = _settings.copyWith(emailEnabled: true);
        }
      }

      _settings = _settings.copyWith(lastError: error);
    } catch (e) {
      // Revert on exception
      _settings = _settings.copyWith(
        emailEnabled: !enabled,
        lastError: 'An error occurred: ${e.toString()}',
      );
    } finally {
      _setToggleLoading('email', false);
    }
  }

  /// Clear last error
  void clearError() {
    _settings = _settings.copyWith(lastError: null);
    notifyListeners();
  }

  /// Refresh settings from API
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }
}

