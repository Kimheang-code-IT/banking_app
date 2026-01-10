/// App Constants
class AppConstants {
  // Storage Keys
  static const String localeKey = 'selected_locale';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Demo Credentials
  static const String demoEmail = 'demo@bank.com';
  static const String demoPassword = 'Password123';

  // Routes
  static const String routeWelcome = '/';
  static const String routeLanguagePicker = '/language-picker';
  static const String routeLogin = '/login';
  static const String routeSignUp = '/signup';
  static const String routeScanId = '/scan-id';
  static const String routeVerifyData = '/verify-data';
  static const String routeSetPassword = '/set-password';
  static const String routeDashboard = '/dashboard';

  // Animation Durations
  static const Duration welcomeAnimationDuration = Duration(milliseconds: 2000);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}

