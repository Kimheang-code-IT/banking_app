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

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
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
      backgroundColor: AppTheme.accentOrange,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.surfaceColor,
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
                      color: AppTheme.surfaceColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.surfaceColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 60,
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingXL),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfaceColor,
                    fontSize: 32,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingM),
                Text(
                  'Enter your phone number to receive a password reset code',
                  style: TextStyle(
                    color: AppTheme.surfaceColor.withOpacity(0.9),
                    fontSize: 16,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textOnLight,
                    fontWeight: FontWeight.w500,
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                    _scrollToField(_phoneFieldKey);
                  },
                  onTapOutside: (event) {
                    _phoneFocusNode.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: '+855 12 345 678',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondaryOnLight.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppTheme.accentOrange,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      borderSide: BorderSide(
                        color: AppTheme.accentOrange.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      borderSide: BorderSide(
                        color: AppTheme.accentOrange.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      borderSide: BorderSide(
                        color: AppTheme.accentOrange,
                        width: 2.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      borderSide: BorderSide(
                        color: AppTheme.errorRed,
                        width: 2.5,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingXL),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Password reset feature coming soon'),
                          backgroundColor: AppTheme.infoBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusXS),
                          ),
                          margin: EdgeInsets.all(AppTheme.spacingM),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor,
                      foregroundColor: AppTheme.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Send Reset Code',
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
}
