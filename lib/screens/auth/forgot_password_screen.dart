import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _scrollController = ScrollController();
  final _phoneFocusNode = FocusNode();
  final _phoneFieldKey = GlobalKey();
  final _phoneController = TextEditingController();
  bool _isPhoneFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
      if (_phoneFocusNode.hasFocus) {
        _scrollToField(_phoneFieldKey);
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
    _scrollController.dispose();
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.textOnLight,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
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
                      Icons.lock_reset,
                      size: 60,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingXL),
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textOnLight,
                      fontSize: 32,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacingM),
              Text(
                'Enter your phone number to receive a password reset code',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryOnLight,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacingXL),
              TextFormField(
                key: _phoneFieldKey,
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                readOnly: false,
                onTap: () {
                  // Ensure keyboard shows by requesting focus
                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                  _scrollToField(_phoneFieldKey);
                },
                onTapOutside: (event) {
                  _phoneFocusNode.unfocus();
                },
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+855 12 345 678',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: _isPhoneFocused
                        ? AppTheme.accentOrange
                        : AppTheme.textSecondaryOnLight,
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Send Reset Code',
                  style: TextStyle(
                    color: AppTheme.surfaceColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
