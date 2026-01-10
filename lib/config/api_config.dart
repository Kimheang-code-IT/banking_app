/// API Configuration
/// 
/// Centralized configuration for API endpoints and settings.
/// Update these values when connecting to your backend.
class ApiConfig {
  // Base URL for API - Change this to your backend URL
  // Example: 'https://api.yourbank.com/v1'
  static const String baseUrl = 'https://api.yourbank.com/v1';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String userEndpoint = '/user';
  static const String accountsEndpoint = '/accounts';
  static const String transactionsEndpoint = '/transactions';
  static const String cardsEndpoint = '/cards';
  static const String billsEndpoint = '/bills';
  static const String messagesEndpoint = '/messages';
  static const String notesEndpoint = '/notes';
  static const String notificationsEndpoint = '/notifications';
  static const String settingsEndpoint = '/me/settings';
  static const String twoFactorEnrollEndpoint = '/me/2fa/enroll';
  static const String twoFactorVerifyEndpoint = '/me/2fa/verify';
  static const String twoFactorDisableEndpoint = '/me/2fa/disable';
  
  // API Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const String contentType = 'application/json';
  static const String acceptHeader = 'application/json';
  
  // Use mock data or real API
  // Set to false when ready to use real backend
  static const bool useMockData = true;
  
  // API Version (if your backend uses versioning)
  static const String apiVersion = 'v1';
}

