import '../models/user.dart';
import 'storage_service.dart';
import '../api/api_service_factory.dart';
import '../api/services/api_service.dart';

/// Auth Service
/// 
/// Handles authentication using the API service abstraction.
/// Works with both mock and real API implementations.
class AuthService {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiServiceFactory.getService();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.data != null) {
        // Save user and token
        final userData = response.data!['user'] as Map<String, dynamic>;
        await _storageService.saveUser(userData);
        await _storageService.setLoggedIn(true);

        // Save token if provided
        if (response.data!.containsKey('token')) {
          // In a real app, save token to secure storage
          // await _secureStorage.saveToken(response.data!['token']);
        }

        return true;
      }

      return false;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  Future<bool> signup(
      String name, String email, String phone, String password) async {
    try {
      final response = await _apiService.signup(name, email, phone, password);

      if (response.success && response.data != null) {
        // Save user but DON'T auto-login
        // User must login manually after signup
        final userData = response.data!['user'] as Map<String, dynamic>;
        await _storageService.saveUser(userData);
        // Don't set isLoggedIn to true - user needs to verify login

        return true;
      }

      return false;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // First try to get from API
      final response = await _apiService.getCurrentUser();
      if (response.success && response.data != null) {
        return response.data;
      }

      // Fallback to local storage
      final userJson = await _storageService.getUser();
      if (userJson != null) {
        return User.fromJson(userJson);
      }
      return null;
    } catch (e) {
      // Fallback to local storage on error
      final userJson = await _storageService.getUser();
      if (userJson != null) {
        return User.fromJson(userJson);
      }
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.setLoggedIn(false);
      // Optionally clear user data but keep accounts/transactions for demo
    }
  }
}
