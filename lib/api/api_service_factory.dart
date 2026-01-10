import '../config/api_config.dart';
import 'services/api_service.dart';
import 'services/mock_api_service.dart';
import 'services/real_api_service.dart';

/// API Service Factory
/// 
/// Creates the appropriate API service based on configuration.
/// Switch between mock and real API by changing ApiConfig.useMockData
class ApiServiceFactory {
  static ApiService? _instance;

  /// Get API service instance (singleton)
  static ApiService getService() {
    _instance ??= _createService();
    return _instance!;
  }

  /// Create API service based on configuration
  static ApiService _createService() {
    if (ApiConfig.useMockData) {
      return MockApiService();
    } else {
      return RealApiService();
    }
  }

  /// Reset instance (useful for testing)
  static void reset() {
    _instance = null;
  }
}

