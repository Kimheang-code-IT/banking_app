import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/currency_service.dart';
import '../../theme/app_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
    
    // Load accounts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Accounts',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
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
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              );
            },
            child: Consumer2<AccountProvider, CurrencyProvider>(
              builder: (context, accountProvider, currencyProvider, _) {
                if (accountProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.surfaceColor,
                      ),
                    ),
                  );
                }

                final accounts = accountProvider.accounts;
                final totalUsdBalance = accountProvider.totalBalance;
                final totalKhrBalance =
                    CurrencyService.convertUsdToRiel(totalUsdBalance);

                return RefreshIndicator(
                  onRefresh: () async {
                    await accountProvider.loadAccounts();
                  },
                  color: AppTheme.surfaceColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Circular Balance Display
                        _buildCircularBalanceDisplay(
                          context,
                          totalUsdBalance,
                          totalKhrBalance,
                          currencyProvider.isBalanceVisible,
                          currencyProvider,
                        ),
                        SizedBox(height: AppTheme.spacingXL),

                        // Accounts List
                        if (accounts.isEmpty)
                          _buildEmptyState(context)
                        else
                          ...accounts.map((account) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppTheme.spacingM,
                                ),
                                child: _buildAccountCard(
                                  context,
                                  account,
                                  currencyProvider.isBalanceVisible,
                                ),
                              )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularBalanceDisplay(
    BuildContext context,
    double usdBalance,
    double khrBalance,
    bool isVisible,
    CurrencyProvider currencyProvider,
  ) {
    // Calculate percentages for the circle
    final usdInKhr = CurrencyService.convertUsdToRiel(usdBalance);
    final totalBalance = khrBalance + usdInKhr;
    final khrPercentage = totalBalance > 0
        ? (khrBalance / totalBalance).clamp(0.0, 1.0)
        : 0.0;
    final usdPercentage = totalBalance > 0
        ? (usdInKhr / totalBalance).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.surfaceColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle with progress
                Container(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _DualCurrencyProgressPainter(
                      khrProgress: khrPercentage,
                      usdProgress: usdPercentage,
                      khrColor: AppTheme.surfaceColor,
                      usdColor: AppTheme.surfaceColor.withOpacity(0.5),
                      strokeWidth: 12,
                    ),
                  ),
                ),
                // Inner circle background
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.surfaceColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: AppTheme.surfaceColor.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXS),
                    Text(
                      isVisible
                          ? CurrencyService.formatUsd(usdBalance)
                          : '••••••',
                      style: TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      isVisible
                          ? CurrencyService.formatRiel(khrBalance)
                          : '••••••',
                      style: TextStyle(
                        color: AppTheme.surfaceColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
          // Balance Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // USD Balance
              _buildBalanceDetail(
                context,
                'USD',
                CurrencyService.formatUsd(usdBalance),
                isVisible,
                AppTheme.surfaceColor,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.surfaceColor.withOpacity(0.3),
              ),
              // KHR Balance
              _buildBalanceDetail(
                context,
                'KHR',
                CurrencyService.formatRiel(khrBalance),
                isVisible,
                AppTheme.surfaceColor.withOpacity(0.8),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingM),
          // Eye icon to toggle visibility
          GestureDetector(
            onTap: () {
              currencyProvider.toggleBalanceVisibility();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: Border.all(
                  color: AppTheme.surfaceColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppTheme.surfaceColor,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingXS),
                  Text(
                    isVisible ? 'Hide Balance' : 'Show Balance',
                    style: TextStyle(
                      color: AppTheme.surfaceColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(
    BuildContext context,
    String currency,
    String amount,
    bool isVisible,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          currency,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          isVisible ? amount : '••••••',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    account,
    bool isVisible,
  ) {
    final usdBalance = account.balance;
    final khrBalance = CurrencyService.convertUsdToRiel(usdBalance);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: Color.fromARGB(255, 66, 129, 177), // Border color (#4281B1)
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountName ?? '${account.type.toUpperCase()} Account',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    account.accountNumber,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Text(
                  account.type.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.surfaceColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingL),
          Divider(
            color: AppTheme.surfaceColor.withOpacity(0.2),
            thickness: 1,
          ),
          SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USD Balance',
                    style: TextStyle(
                      color: AppTheme.textPrimary.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isVisible
                        ? CurrencyService.formatUsd(usdBalance)
                        : '••••••',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'KHR Balance',
                    style: TextStyle(
                      color: AppTheme.textPrimary.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isVisible
                        ? CurrencyService.formatRiel(khrBalance)
                        : '••••••',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.surfaceColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppTheme.surfaceColor.withOpacity(0.5),
            size: 64,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'No Accounts Found',
            style: TextStyle(
              color: AppTheme.surfaceColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spacingXS),
          Text(
            'Your accounts will appear here',
            style: TextStyle(
              color: AppTheme.surfaceColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dual currency circular progress indicator
class _DualCurrencyProgressPainter extends CustomPainter {
  final double khrProgress;
  final double usdProgress;
  final Color khrColor;
  final Color usdColor;
  final double strokeWidth;

  _DualCurrencyProgressPainter({
    required this.khrProgress,
    required this.usdProgress,
    required this.khrColor,
    required this.usdColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Start from top (-90 degrees)
    final startAngle = -3.14159 / 2; // -90 degrees

    // Draw KHR segment first (white)
    if (khrProgress > 0) {
      final khrPaint = Paint()
        ..color = khrColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final khrSweepAngle = 2 * 3.14159 * khrProgress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        khrSweepAngle,
        false,
        khrPaint,
      );
    }

    // Draw USD segment after KHR
    if (usdProgress > 0) {
      final usdPaint = Paint()
        ..color = usdColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final usdStartAngle = startAngle + (2 * 3.14159 * khrProgress);
      final usdSweepAngle = 2 * 3.14159 * usdProgress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        usdStartAngle,
        usdSweepAngle,
        false,
        usdPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DualCurrencyProgressPainter oldDelegate) {
    return oldDelegate.khrProgress != khrProgress ||
        oldDelegate.usdProgress != usdProgress ||
        oldDelegate.khrColor != khrColor ||
        oldDelegate.usdColor != usdColor;
  }
}

