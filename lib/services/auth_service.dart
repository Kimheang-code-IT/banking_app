import '../models/user.dart';
import 'storage_service.dart';
import 'mock_data_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();
  final MockDataService _mockDataService = MockDataService();

  Future<bool> login(String email, String password) async {
    // In a real app, this would make an API call
    // For now, we'll use mock data
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation - in real app, check against backend
    if (email.isNotEmpty && password.isNotEmpty) {
      final user = _mockDataService.getDefaultUser();
      await _storageService.saveUser(user.toJson());
      await _storageService.setLoggedIn(true);
      
      // Initialize mock data if not already initialized
      final accounts = await _storageService.getAccounts();
      if (accounts.isEmpty) {
        await _mockDataService.initializeMockData();
      }
      
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      
      await _storageService.saveUser(user.toJson());
      await _storageService.setLoggedIn(true);
      
      // Initialize mock data for new user
      await _mockDataService.initializeMockData();
      
      return true;
    }
    return false;
  }

  Future<User?> getCurrentUser() async {
    final userJson = await _storageService.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  Future<void> logout() async {
    await _storageService.setLoggedIn(false);
    // Optionally clear user data but keep accounts/transactions for demo
  }
}

