import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../language/language_picker_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward().then((_) {
        // Auto-advance after animation completes
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToNextScreen();
        });
      });
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Don't mark welcome as shown - we want it to show every time
    // Navigate to language picker with fade and scale transition
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LanguagePickerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            // Scale transition
            final scaleAnimation = Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Animated Logo with splash effect
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_animationController, _pulseController]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value * _pulseAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.surfaceColor,
                                    AppTheme.surfaceColor.withOpacity(0.9),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.surfaceColor.withOpacity(
                                        0.3 * _opacityAnimation.value),
                                    blurRadius: 40 * _pulseAnimation.value,
                                    spreadRadius: 15 * _pulseAnimation.value,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.account_balance,
                                size: 110,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacingXL),
                  // App Name
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Text(
                          'GEN-Z BANK',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.surfaceColor,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppTheme.spacingL),
                  // Subtitle
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
                    child: Text(
                      'Fast KHQR payments. Simple banking in Cambodia.',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.surfaceColor.withOpacity(0.95),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  // Loading indicator during navigation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      if (_animationController.value < 0.9) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                          vertical: AppTheme.spacingXL,
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.surfaceColor,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacingM),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                color: AppTheme.surfaceColor.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
