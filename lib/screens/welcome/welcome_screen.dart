import 'dart:math' as math;
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
    // Longer animation duration for better effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Enhanced scale animation with bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Fade in animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Subtle rotation animation
    _rotationAnimation = Tween<double>(
      begin: -0.15,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Continuous pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward().then((_) {
        // Wait a bit longer after animation completes before navigating
        Future.delayed(const Duration(milliseconds: 800), () {
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
              AppTheme.accentOrange.withOpacity(0.95),
              AppTheme.accentOrange.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background circles/waves
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: WavePainter(_pulseAnimation.value),
                    ),
                  );
                },
              ),
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                        // Animated Logo with enhanced splash effect
                        AnimatedBuilder(
                          animation: Listenable.merge(
                              [_animationController, _pulseController]),
                          builder: (context, child) {
                            return Transform.scale(
                              scale:
                                  _scaleAnimation.value * _pulseAnimation.value,
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer glow ring
                                      if (_opacityAnimation.value > 0.5)
                                        Container(
                                          width: 220 * _pulseAnimation.value,
                                          height: 220 * _pulseAnimation.value,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                AppTheme.surfaceColor
                                                    .withOpacity(0.2 *
                                                        _opacityAnimation
                                                            .value),
                                                AppTheme.surfaceColor
                                                    .withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      // Main logo container
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.surfaceColor,
                                              AppTheme.surfaceColor
                                                  .withOpacity(0.95),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.surfaceColor
                                                  .withOpacity(0.4 *
                                                      _opacityAnimation.value),
                                              blurRadius:
                                                  50 * _pulseAnimation.value,
                                              spreadRadius:
                                                  10 * _pulseAnimation.value,
                                            ),
                                            BoxShadow(
                                              color: AppTheme.accentOrange
                                                  .withOpacity(0.3 *
                                                      _opacityAnimation.value),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.account_balance,
                                          size: 110,
                                          color: AppTheme.accentOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: AppTheme.spacingXXL),
                        // App Name with staggered animation
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final textOpacity = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            )
                                .animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(0.4, 0.8,
                                        curve: Curves.easeOut),
                                  ),
                                )
                                .value;

                            final textScale = Tween<double>(
                              begin: 0.8,
                              end: 1.0,
                            )
                                .animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(0.4, 0.8,
                                        curve: Curves.elasticOut),
                                  ),
                                )
                                .value;

                            return Opacity(
                              opacity: textOpacity,
                              child: Transform.scale(
                                scale: textScale,
                                child: Text(
                                  'GEN-Z BANK',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.surfaceColor,
                                    letterSpacing: 3.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: AppTheme.spacingL),
                        // Subtitle with fade in
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final subtitleOpacity = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            )
                                .animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(0.6, 1.0,
                                        curve: Curves.easeOut),
                                  ),
                                )
                                .value;

                            return Opacity(
                              opacity: subtitleOpacity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingXL,
                                ),
                                child: Text(
                                  'Fast KHQR payments. Simple banking in Cambodia.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        AppTheme.surfaceColor.withOpacity(0.95),
                                    height: 1.6,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        // Loading indicator during navigation
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final loadingOpacity = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            )
                                .animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(0.85, 1.0,
                                        curve: Curves.easeIn),
                                  ),
                                )
                                .value;

                            if (_animationController.value < 0.85) {
                              return const SizedBox.shrink();
                            }

                            return Opacity(
                              opacity: loadingOpacity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingL,
                                  vertical: AppTheme.spacingXL,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          AppTheme.surfaceColor,
                                        ),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.spacingM),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: AppTheme.surfaceColor
                                            .withOpacity(0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
}

// Custom painter for animated wave background
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw animated waves
    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 2;
    final baseY = size.height * 0.8;

    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x++) {
      final y = baseY +
          waveHeight *
              math.sin((x / waveLength + animationValue * 2) * 2 * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
