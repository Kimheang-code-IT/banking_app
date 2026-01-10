/// Settings Model
/// 
/// Represents user settings state including authentication preferences,
/// notification preferences, and app metadata.
class Settings {
  final bool biometricEnabled;
  final bool twoFactorEnabled;
  final bool pushEnabled;
  final bool emailEnabled;
  final String appVersion;
  final bool isLoadingInitial;
  final Map<String, bool> perToggleLoading;
  final String? lastError;

  const Settings({
    this.biometricEnabled = false,
    this.twoFactorEnabled = false,
    this.pushEnabled = false,
    this.emailEnabled = false,
    required this.appVersion,
    this.isLoadingInitial = false,
    Map<String, bool>? perToggleLoading,
    this.lastError,
  }) : perToggleLoading = perToggleLoading ?? const {};

  Settings copyWith({
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    String? appVersion,
    bool? isLoadingInitial,
    Map<String, bool>? perToggleLoading,
    String? lastError,
  }) {
    return Settings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      appVersion: appVersion ?? this.appVersion,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      perToggleLoading: perToggleLoading ?? this.perToggleLoading,
      lastError: lastError ?? this.lastError,
    );
  }

  /// Create Settings from JSON (API response)
  factory Settings.fromJson(Map<String, dynamic> json, String appVersion) {
    return Settings(
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      pushEnabled: json['pushEnabled'] as bool? ?? false,
      emailEnabled: json['emailEnabled'] as bool? ?? false,
      appVersion: appVersion,
    );
  }

  /// Convert Settings to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'biometricEnabled': biometricEnabled,
      'twoFactorEnabled': twoFactorEnabled,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
    };
  }
}

/// Two-Factor Authentication Enroll Response
class TwoFactorEnrollResponse {
  final String method; // "sms", "email", "totp"
  final String challengeId;

  TwoFactorEnrollResponse({
    required this.method,
    required this.challengeId,
  });

  factory TwoFactorEnrollResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorEnrollResponse(
      method: json['method'] as String,
      challengeId: json['challengeId'] as String,
    );
  }
}

