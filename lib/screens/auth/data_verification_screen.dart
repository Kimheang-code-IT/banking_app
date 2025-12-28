import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class DataVerificationScreen extends StatefulWidget {
  const DataVerificationScreen({super.key});

  @override
  State<DataVerificationScreen> createState() => _DataVerificationScreenState();
}

class _DataVerificationScreenState extends State<DataVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _scrollController = ScrollController();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  bool _isEditing = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _loadScannedData();
  }

  Future<void> _loadScannedData() async {
    final scannedData = await _storageService.getScannedIdData();
    if (scannedData != null) {
      setState(() {
        _nameController.text = scannedData['name'] ?? '';
        _idNumberController.text = scannedData['idNumber'] ?? '';
        _dateOfBirthController.text = scannedData['dateOfBirth'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passwords do not match'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
        return;
      }

      // Check terms agreement
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please agree to the Terms & Conditions'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Create account
      final success = await _authService.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
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
            content: const Text('Failed to create account'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 60,
        leadingWidth: 70,
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Verify Your Information',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppTheme.surfaceColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                          color: AppTheme.accentOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.accentOrange,
                            size: 24,
                          ),
                          SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Text(
                              'Please verify the information extracted from your ID card and complete the remaining fields.',
                              style: TextStyle(
                                color: AppTheme.textOnLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    // Scanned Data Section
                    Text(
                      'ID Card Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textOnLight,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Name (from ID card)
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outlined),
                        suffixIcon: _isEditing
                            ? null
                            : Icon(
                                Icons.check_circle,
                                color: AppTheme.accentOrange,
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // ID Number (from ID card)
                    TextFormField(
                      controller: _idNumberController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'ID Number',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        suffixIcon: _isEditing
                            ? null
                            : Icon(
                                Icons.check_circle,
                                color: AppTheme.accentOrange,
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your ID number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Date of Birth (from ID card)
                    TextFormField(
                      controller: _dateOfBirthController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: _isEditing
                            ? null
                            : Icon(
                                Icons.check_circle,
                                color: AppTheme.accentOrange,
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    // Additional Information Section
                    Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textOnLight,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+855 12 345 678',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    // Terms & Conditions Agreement
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                          color: AppTheme.accentOrange.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textOnLight,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingS),
                          Text(
                            '1. Introduction: Welcome to our banking application. By using this service, you agree to be bound by these Terms and Conditions.\n\n'
                            '2. KHQR Payment Usage: KHQR is a standardized QR code payment system in Cambodia. Transactions are processed securely.\n\n'
                            '3. Security & Privacy: We are committed to protecting your personal and financial information. All data is encrypted and stored securely.\n\n'
                            '4. Fees and Limits: Transaction fees and account limits may apply as per our fee schedule.\n\n'
                            '5. Governing Law: These Terms are governed by the laws of the Kingdom of Cambodia.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryOnLight,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingM),
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                                activeColor: AppTheme.accentOrange,
                              ),
                              Expanded(
                                child: Text(
                                  'I agree to the Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textOnLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    // Continue Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _handleContinue,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: AppTheme.spacingL),
                  ],
                ),
              ),
            ),
    );
  }
}
