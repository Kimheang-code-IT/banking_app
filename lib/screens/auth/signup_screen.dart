import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'login_screen.dart';
import 'terms_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _scrollController = ScrollController();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _nameFieldKey = GlobalKey();
  final _phoneFieldKey = GlobalKey();
  final _emailFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _confirmPasswordFieldKey = GlobalKey();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
 
  bool _isPhoneFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update button state
    _nameController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);

    // Add focus listeners
    _nameFocusNode.addListener(() {
     
      if (_nameFocusNode.hasFocus) {
        _scrollToField(_nameFieldKey);
      }
    });
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
      if (_phoneFocusNode.hasFocus) {
        _scrollToField(_phoneFieldKey);
      }
    });
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
      if (_emailFocusNode.hasFocus) {
        _scrollToField(_emailFieldKey);
      }
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
      if (_passwordFocusNode.hasFocus) {
        _scrollToField(_passwordFieldKey);
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
      });
      if (_confirmPasswordFocusNode.hasFocus) {
        _scrollToField(_confirmPasswordFieldKey);
      }
    });
  }

  void _scrollToField(GlobalKey key) {
    // Wait for keyboard to appear, then scroll smoothly
    Future.delayed(const Duration(milliseconds: 150), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: 0.1, // Better positioning - 10% from top
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _phoneController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _confirmPasswordController.removeListener(_updateButtonState);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      // Trigger rebuild to update button state
    });
  }

  bool _isFormValid() {
    // Check all fields are not empty
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      return false;
    }

    // Check email format
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return false;
    }

    // Check passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      return false;
    }

    // Check terms agreement
    if (!_agreeToTerms) {
      return false;
    }

    return true;
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      // Check password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text('Passwords do not match'),
                ),
              ],
            ),
            backgroundColor: AppTheme.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusL)),
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
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text('Please agree to the Terms & Conditions'),
                ),
              ],
            ),
            backgroundColor: AppTheme.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusL)),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
        return;
      }

      // Success - show SnackBar and navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully (mock)'),
            backgroundColor: AppTheme.accentOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusL)),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  Future<void> _viewTerms() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsScreen(),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _agreeToTerms = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(
            left: AppTheme.spacingL,
            right: AppTheme.spacingL,
            top: AppTheme.spacingL,
            bottom: AppTheme.spacingL + keyboardHeight,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                SizedBox(height: AppTheme.spacingL),
                // Logo/Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.surfaceColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      size: 60,
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingXL),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfaceColor,
                    fontSize: 32,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingL),
                TextFormField(
                  key: _nameFieldKey,
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  readOnly: false,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                    _scrollToField(_nameFieldKey);
                  },
                  onTapOutside: (event) {
                    _nameFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(
                      color: AppTheme.accentOrange.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    labelStyle: TextStyle(
                        color: AppTheme.accentOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outlined,
                        color: AppTheme.accentOrange,
                      size: 22,
                    ),
                    filled: true,
                      fillColor: AppTheme.surfaceColor,
                    errorStyle: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.surfaceColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor,
                          width: 3,
                        ),
                      ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
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
                TextFormField(
                  key: _phoneFieldKey,
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  readOnly: false,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                    _scrollToField(_phoneFieldKey);
                  },
                  onTapOutside: (event) {
                    _phoneFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+855 12 345 678',
                    hintStyle: TextStyle(
                      color: AppTheme.accentOrange.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    labelStyle: TextStyle(
                        color: AppTheme.accentOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                        color: AppTheme.accentOrange,
                      size: 22,
                    ),
                    filled: true,
                      fillColor: AppTheme.surfaceColor,
                    errorStyle: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: _isPhoneFocused
                            ? AppTheme.accentOrange
                            : AppTheme.dividerColor,
                        width: _isPhoneFocused ? 2 : 1,
                      ),
                    ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor,
                          width: 3,
                        ),
                      ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppTheme.spacingM),
                TextFormField(
                  key: _emailFieldKey,
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  readOnly: false,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                    _scrollToField(_emailFieldKey);
                  },
                  onTapOutside: (event) {
                    _emailFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(
                      color: AppTheme.accentOrange.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    labelStyle: TextStyle(
                        color: AppTheme.accentOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                        color: AppTheme.accentOrange,
                      size: 22,
                    ),
                    filled: true,
                      fillColor: AppTheme.surfaceColor,
                    errorStyle: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: _isEmailFocused
                            ? AppTheme.accentOrange
                            : AppTheme.dividerColor,
                        width: _isEmailFocused ? 2 : 1,
                      ),
                    ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor,
                          width: 3,
                        ),
                      ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
                    ),
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
                TextFormField(
                  key: _passwordFieldKey,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  keyboardType: _obscurePassword
                      ? TextInputType.text
                      : TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  readOnly: false,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                    _scrollToField(_passwordFieldKey);
                  },
                  onTapOutside: (event) {
                    _passwordFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    hintStyle: TextStyle(
                      color: AppTheme.accentOrange.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    labelStyle: TextStyle(
                        color: AppTheme.accentOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                        color: AppTheme.accentOrange,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.accentOrange,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                      fillColor: AppTheme.surfaceColor,
                    errorStyle: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: _isPasswordFocused
                            ? AppTheme.accentOrange
                            : AppTheme.dividerColor,
                        width: _isPasswordFocused ? 2 : 1,
                      ),
                    ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor,
                          width: 3,
                        ),
                      ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppTheme.spacingM),
                TextFormField(
                  key: _confirmPasswordFieldKey,
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: _obscureConfirmPassword,
                  keyboardType: _obscureConfirmPassword
                      ? TextInputType.text
                      : TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignup(),
                  readOnly: false,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                    _scrollToField(_confirmPasswordFieldKey);
                  },
                  onTapOutside: (event) {
                    _confirmPasswordFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    hintStyle: TextStyle(
                      color: AppTheme.accentOrange.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    labelStyle: TextStyle(
                        color: AppTheme.accentOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                        color: AppTheme.accentOrange,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.accentOrange,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                      fillColor: AppTheme.surfaceColor,
                    errorStyle: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: _isConfirmPasswordFocused
                            ? AppTheme.accentOrange
                            : AppTheme.dividerColor,
                        width: _isConfirmPasswordFocused ? 2 : 1,
                      ),
                    ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        borderSide: BorderSide(
                          color: AppTheme.surfaceColor,
                          width: 3,
                        ),
                      ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
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
                SizedBox(height: AppTheme.spacingL),
                // Terms & Conditions Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                        _updateButtonState();
                      },
                      activeColor: AppTheme.accentOrange,
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'I agree to the ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textOnLight,
                                ),
                          ),
                          TextButton(
                            onPressed: _viewTerms,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingXL),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isFormValid() ? _handleSignup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor,
                      foregroundColor: AppTheme.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.surfaceColor.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.surfaceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
