import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// Two-Factor Authentication Verification Screen
/// 
/// Displays after user enables 2FA to verify the code
class TwoFactorVerificationScreen extends StatefulWidget {
  final String challengeId;

  const TwoFactorVerificationScreen({
    super.key,
    required this.challengeId,
  });

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final success = await settingsProvider.verifyTwoFactor(
      widget.challengeId,
      _codeController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Two-factor authentication enabled successfully'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
    } else {
      // Error is already set in provider
      final error = settingsProvider.settings.lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Verification failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Verify Code',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.surfaceColor),
      ),
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.security,
                  size: 64,
                  color: AppTheme.accentOrange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textOnLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enter the verification code sent to your registered phone number or email',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryOnLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter 6-digit code',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.length < 4) {
                      return 'Code must be at least 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<SettingsProvider>(
                  builder: (context, provider, _) {
                    final isLoading = provider.isToggleLoading('twoFactor');
                    return ElevatedButton(
                      onPressed: isLoading ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: AppTheme.surfaceColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.surfaceColor,
                                ),
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

