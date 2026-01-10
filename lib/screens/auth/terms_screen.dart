import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleAgree() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all collected data from storage
      final scannedData = await _storageService.getScannedIdData();
      if (scannedData == null) {
        throw Exception('No registration data found');
      }

      final name = scannedData['name'] as String? ?? '';
      final phone = scannedData['phone'] as String? ?? '';
      final password = scannedData['password'] as String? ?? '';

      // Validate required fields
      if (name.isEmpty || phone.isEmpty || password.isEmpty) {
        throw Exception('Missing required information');
      }

      // Generate email from name (or use phone as email for now)
      final email = scannedData['email'] as String? ??
          '${name.toLowerCase().replaceAll(' ', '.')}@banking.app';

      // Create account
      final success = await _authService.signup(
        name,
        email,
        phone,
        password,
      );

      if (success && mounted) {
        // Mark onboarding as complete
        await _storageService.setOnboardingCompleted(true);

        // Navigate to Login Screen (not Dashboard) - user must verify login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create account. Please try again.'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentOrange,
              AppTheme.accentOrange.withOpacity(0.9),
              AppTheme.accentOrange.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.surfaceColor,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.surfaceColor,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 20), // Balance the back button
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: '1. Introduction',
                      content:
                          'Welcome to our banking application. By using this service, you agree to be bound by these Terms and Conditions. Please read them carefully before proceeding.',
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    _buildSection(
                      context,
                      title: '2. KHQR Payment Usage',
                      content:
                          'KHQR is a standardized QR code payment system in Cambodia. When using KHQR payments, you agree to comply with all applicable regulations and guidelines. Transactions are processed securely through authorized payment networks.',
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    _buildSection(
                      context,
                      title: '3. Security & Privacy',
                      content:
                          'We are committed to protecting your personal and financial information. All data is encrypted and stored securely. You are responsible for maintaining the confidentiality of your account credentials. Report any suspicious activity immediately.',
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    _buildSection(
                      context,
                      title: '4. Fees and Limits',
                      content:
                          'Transaction fees and account limits may apply as per our fee schedule. These may vary based on account type and transaction volume. Please review the current fee structure in your account settings.',
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    _buildSection(
                      context,
                      title: '5. Governing Law (Cambodia)',
                      content:
                          'These Terms and Conditions are governed by the laws of the Kingdom of Cambodia. Any disputes arising from the use of this service shall be subject to the exclusive jurisdiction of Cambodian courts.',
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAgree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColor,
                    foregroundColor: AppTheme.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentOrange,
                            ),
                          ),
                        )
                      : Text(
                          'I Agree',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.surfaceColor,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: AppTheme.spacingM),
        Text(
          content,
          style: TextStyle(
            color: AppTheme.surfaceColor.withOpacity(0.9),
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
