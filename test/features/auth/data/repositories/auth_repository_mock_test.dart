import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banking_app/features/auth/data/repositories/auth_repository_mock.dart';
import 'package:banking_app/core/constants/app_constants.dart';
import 'package:banking_app/features/kyc/domain/entities/kyc_data.dart';

void main() {
  group('AuthRepositoryMock', () {
    late AuthRepositoryMock repository;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = AuthRepositoryMock(prefs);
    });

    test('login with demo credentials should succeed', () async {
      final result = await repository.login(
        AppConstants.demoEmail,
        AppConstants.demoPassword,
      );

      expect(result.success, true);
      expect(result.token, isNotNull);
      expect(result.user, isNotNull);
      expect(result.user?.email, AppConstants.demoEmail);
    });

    test('login with invalid credentials should fail', () async {
      final result = await repository.login(
        'wrong@email.com',
        'wrongpassword',
      );

      expect(result.success, false);
      expect(result.error, isNotNull);
      expect(result.token, isNull);
    });

    test('register should create new user and allow login', () async {
      final kycData = VerifiedKycData(
        fullName: 'Test User',
        gender: 'Male',
        idNumber: 'TEST123',
      );

      final registerResult = await repository.register(kycData, 'TestPassword123');
      expect(registerResult.success, true);

      // Now try to login with the registered credentials
      final email = '${kycData.fullName.toLowerCase().replaceAll(' ', '.')}@bank.com';
      final loginResult = await repository.login(email, 'TestPassword123');
      expect(loginResult.success, true);
      expect(loginResult.user?.name, kycData.fullName);
    });

    test('logout should clear authentication', () async {
      // First login
      await repository.login(AppConstants.demoEmail, AppConstants.demoPassword);
      expect(await repository.isAuthenticated(), true);

      // Then logout
      await repository.logout();
      expect(await repository.isAuthenticated(), false);
    });
  });
}

