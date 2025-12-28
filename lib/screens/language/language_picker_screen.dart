import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  Locale? _selectedLanguage;

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance,
                    size: 60,
                    color: AppTheme.surfaceColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfaceColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'ជ្រើសរើសភាសា',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.surfaceColor.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Language Options
                _buildLanguageOption(
                  context,
                  locale: const Locale('en'),
                  title: 'English',
                  subtitle: 'Continue in English',
                  flag: '🇬🇧',
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                  context,
                  locale: const Locale('km'),
                  title: 'ភាសាខ្មែរ',
                  subtitle: 'បន្តជាភាសាខ្មែរ',
                  flag: '🇰🇭',
                ),
                const SizedBox(height: 48),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLanguage == null
                        ? null
                        : () async {
                            final languageProvider =
                                Provider.of<LanguageProvider>(context,
                                    listen: false);
                            await languageProvider
                                .setLanguage(_selectedLanguage!);

                            if (mounted) {
                              // Always navigate to Login Screen after language selection
                              // Login screen will handle authentication and signup flow
                              final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              await authProvider.checkAuthStatus();

                              if (mounted) {
                                if (authProvider.isAuthenticated) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor,
                      foregroundColor: AppTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required Locale locale,
    required String title,
    required String subtitle,
    required String flag,
  }) {
    final isSelected = _selectedLanguage?.languageCode == locale.languageCode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = locale;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.surfaceColor
              : AppTheme.surfaceColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? AppTheme.surfaceColor
                : AppTheme.surfaceColor.withOpacity(0.5),
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.accentOrange
                          : AppTheme.surfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppTheme.accentOrange.withOpacity(0.7)
                          : AppTheme.surfaceColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Check Icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.accentOrange,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
