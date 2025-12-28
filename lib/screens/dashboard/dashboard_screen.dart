import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/currency_service.dart';
import '../../theme/app_theme.dart';
import '../transfer/transfer_screen.dart';
import '../cards/cards_screen.dart';
import '../qr_scanner/qr_display_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import '../notification/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../deposit/deposit_screen.dart';
import '../withdraw/withdraw_screen.dart';
import '../payment/payment_card_mobile_screen.dart';
import '../report/report_screen.dart';
import '../exchange_rate/exchange_rate_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _shrinkPercent = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Create scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Setup scroll listener
    _scrollController.addListener(_handleScroll);

    // Load accounts and start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AccountProvider>(context, listen: false).loadAccounts();
        // Start entrance animation
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final percent =
        (_scrollController.offset / 140).clamp(0.0, 1.0); // smooth shrink
    if (percent != _shrinkPercent) {
      setState(() {
        _shrinkPercent = percent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 60,
        leadingWidth: 70,
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(
            Icons.account_balance,
            color: AppTheme.surfaceColor,
            size: 28,
          ),
        ),
        title: const Text(
          'GEN-Z BANK',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppTheme.surfaceColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code,
                color: AppTheme.surfaceColor, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRDisplayScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(
          255, 23, 52, 84), // Dashboard background - Blue (#173454)
      body: SafeArea(
        bottom: true,
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
          child: RefreshIndicator(
            onRefresh: () async {
              if (!context.mounted) return;
              await Provider.of<AccountProvider>(context, listen: false)
                  .loadAccounts();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section (Dark Blue)
                  _buildHeader(context),

                  // Account Summary Card (White)
                  _buildAccountSummaryCard(context),

                  _buildServicesGrid(context),

                  SizedBox(height: AppTheme.spacingM),

                  // Explore Services Section

                  _buildExploreServices(context),

                  SizedBox(height: AppTheme.spacingM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.currentUser?.name ?? 'User';
        final initials = userName.length >= 2
            ? userName.substring(0, 2).toUpperCase()
            : userName.toUpperCase();

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingM,
          ),
          color: AppTheme.accentOrange,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.surfaceColor.withOpacity(0.2),
                radius: 28,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: AppTheme.surfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18 - (4 * _shrinkPercent),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hello, ${userName.toUpperCase()}',
                      style: TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 18 - (3 * _shrinkPercent),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Profile',
                            style: TextStyle(
                              color: AppTheme.surfaceColor.withOpacity(0.8),
                              fontSize: 13 - (1 * _shrinkPercent),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.surfaceColor.withOpacity(0.8),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSummaryCard(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        if (accountProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(4),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final primaryAccount = accountProvider.primaryAccount;
        if (primaryAccount == null) {
          return const SizedBox.shrink();
        }

        return Consumer<CurrencyProvider>(
          builder: (context, currencyProvider, _) {
            final usdBalance = primaryAccount.balance;
            final rielBalance = CurrencyService.convertUsdToRiel(usdBalance);

            return Container(
              margin: EdgeInsets.all(AppTheme.spacingM),
              padding: EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Color.fromARGB(
                    255, 18, 42, 68), // Card background - Dark blue (#122A44)
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(
                  color: Color.fromARGB(
                      255, 66, 129, 177), // Border color (#4281B1)
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Circular account analytics widget
                  _buildAccountAnalyticsCircle(
                    context,
                    khrBalance: rielBalance,
                    usdBalance: usdBalance,
                  ),
                  // Right: Total Balance header and balances
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Total Balance text and eye icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'សមតុល្យសរុប',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(width: AppTheme.spacingM),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  currencyProvider.isBalanceVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppTheme.surfaceColor,
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  currencyProvider.toggleBalanceVisibility();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        // KHR balance with symbol
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            currencyProvider.isBalanceVisible
                                ? CurrencyService.formatRiel(rielBalance)
                                : '••••• ៛',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: -0.5,
                                ),
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingS),
                        // USD balance with symbol
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            currencyProvider.isBalanceVisible
                                ? CurrencyService.formatUsd(usdBalance)
                                : '••••• \$',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccountAnalyticsCircle(
    BuildContext context, {
    required double khrBalance,
    required double usdBalance,
  }) {
    // Convert USD to KHR for total calculation
    final usdInKhr = CurrencyService.convertUsdToRiel(usdBalance);
    final totalBalance = khrBalance + usdInKhr;

    // Calculate percentages
    final khrPercentage =
        totalBalance > 0 ? (khrBalance / totalBalance).clamp(0.0, 1.0) : 0.0;
    final usdPercentage =
        totalBalance > 0 ? (usdInKhr / totalBalance).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle with border and progress indicator
          Container(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DualCurrencyProgressPainter(
                khrProgress: khrPercentage,
                usdProgress: usdPercentage,
                khrColor: AppTheme.surfaceColor,
                usdColor: AppTheme.surfaceColor.withOpacity(0.5),
                strokeWidth: 10,
              ),
            ),
          ),
          // Inner circle background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    Color.fromARGB(255, 66, 129, 177), // Border color (#4281B1)
                width: 2,
              ),
            ),
          ),
          // Wallet icon and text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.surfaceColor,
                  size: 32,
                ),
              ),
              SizedBox(height: AppTheme.spacingXS),
              Text(
                'គណនី',
                style: TextStyle(
                  color: AppTheme.surfaceColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Row 1: Deposit, Cards, Withdraw
          Row(
            children: [
              Expanded(
                child: _buildServiceButton(
                  context,
                  icon: Icons.savings,
                  label: 'Deposit',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DepositScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildServiceButton(
                  context,
                  icon: Icons.credit_card,
                  label: 'Cards',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CardsScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildServiceButton(
                  context,
                  icon: Icons.money_off,
                  label: 'Withdraw',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WithdrawScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingL),
          // Row 2: ABA Scan, Transfers, Payment
          Row(
            children: [
              Expanded(
                child: _buildServiceButton(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QRScannerScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildServiceButton(
                  context,
                  icon: Icons.swap_horiz,
                  label: 'Transfers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransferScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildServiceButton(
                  context,
                  icon: Icons.phone_android,
                  label: 'Payment',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentCardMobileScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTheme.spacingL,
            horizontal: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color:
                  Color.fromARGB(255, 66, 129, 177), // Border color (#4281B1)
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 56px container with 28px icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.surfaceColor,
                  size: 28,
                ),
              ),
              SizedBox(height: AppTheme.spacingM),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreServices(BuildContext context) {
    final services = [
      {
        'icon': Icons.book,
        'label': 'Exchange rate',
        'color': AppTheme.accentOrange
      },
      {
        'icon': Icons.local_offer,
        'label': 'Report',
        'color': AppTheme.accentOrange
      },
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: AppTheme.spacingM),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (service['label'] == 'Exchange rate') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExchangeRateScreen(),
                      ),
                    );
                  } else if (service['label'] == 'Report') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportScreen(),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: Color.fromARGB(
                          255, 66, 129, 177), // Border color (#4281B1)
                      width: 2,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppTheme.spacingS),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Icon(
                          service['icon'] as IconData,
                          color: AppTheme.surfaceColor,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          service['label'] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

    // Draw USD segment after KHR (orange)
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
