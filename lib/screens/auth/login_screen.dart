import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';
import '../../screens/main_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  bool _obscurePassword = true;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Check if email and password are not empty
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      bool hasError = false;

      if (email.isEmpty) {
        setState(() {
          // Trigger validation
        });
        _formKey.currentState!.validate();
        hasError = true;
      }

      if (password.isEmpty) {
        setState(() {
          // Trigger validation
        });
        _formKey.currentState!.validate();
        hasError = true;
      }

      if (hasError) {
        return;
      }

      // If both filled, show success SnackBar and navigate to dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login success (mock)'),
            backgroundColor: AppTheme.accentOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );

        // Navigate to main screen (with bottom navigation) with custom fade transition
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  (AppTheme.spacingL * 2) -
                  keyboardHeight,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentOrange,
                            AppTheme.accentOrange.withOpacity(0.9),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentOrange.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: 60,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXL),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnLight,
                          fontSize: 32,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.spacingXL),
                  // Email Field
                  TextFormField(
                    key: _emailFieldKey,
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    enabled: true,
                    readOnly: false,
                    onTap: () {
                      // Ensure keyboard shows by requesting focus
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                      _scrollToField(_emailFieldKey);
                    },
                    onTapOutside: (event) {
                      // Allow unfocus when tapping outside
                      _emailFocusNode.unfocus();
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondaryOnLight.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      labelStyle: TextStyle(
                        color: _isEmailFocused
                            ? AppTheme.accentOrange
                            : AppTheme.textSecondaryOnLight,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: _isEmailFocused
                            ? AppTheme.accentOrange
                            : AppTheme.textSecondaryOnLight,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Simple email validation
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  // Password Field
                  TextFormField(
                    key: _passwordFieldKey,
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    enabled: true,
                    readOnly: false,
                    onTap: () {
                      // Ensure keyboard shows by requesting focus
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                      _scrollToField(_passwordFieldKey);
                    },
                    onTapOutside: (event) {
                      // Allow unfocus when tapping outside
                      _passwordFocusNode.unfocus();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondaryOnLight.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      labelStyle: TextStyle(
                        color: _isPasswordFocused
                            ? AppTheme.accentOrange
                            : AppTheme.textSecondaryOnLight,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: _isPasswordFocused
                            ? AppTheme.accentOrange
                            : AppTheme.textSecondaryOnLight,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondaryOnLight,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Log In',
                      onPressed: _handleLogin,
                      isLoading: false,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryOnLight,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w600,
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
