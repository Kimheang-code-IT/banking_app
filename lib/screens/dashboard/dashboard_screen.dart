import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
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
import '../account/account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  double _shrinkPercent = 0.0;
  int _currentSlideIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _slideshowTimer;

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
        // Start slideshow auto-advance
        _startSlideshow();
      }
    });
  }

  void _startSlideshow() {
    _slideshowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && mounted) {
        _currentSlideIndex = (_currentSlideIndex + 1) % 3; // 3 slides
        _pageController.animateToPage(
          _currentSlideIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onSlideChanged(int index) {
    setState(() {
      _currentSlideIndex = index;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _slideshowTimer?.cancel();
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
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        leadingWidth: 70,
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
                    // Profile Section at Top with Account Info
                    _buildHeader(context),

                    // Slideshow Card
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
          padding: EdgeInsets.only(
            left: AppTheme.spacingM,
            right: AppTheme.spacingM,
            top: AppTheme.spacingM,
            bottom: AppTheme.spacingXS,
          ),
          child: Row(
            children: [
              // Profile Section - Left Side
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
              // Account UI - Right Side
              _buildAccountInfo(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, _) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountScreen(),
              ),
            );
          },
          child: Container(
            width: 70,
            height: 70,
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.cardGray,
              shape: BoxShape.circle,
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
                Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.surfaceColor,
                  size: 28,
                ),
                SizedBox(height: 2),
                Text(
                  'Account',
                  style: TextStyle(
                    color: AppTheme.surfaceColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSummaryCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth * 0.5; // Responsive height

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppTheme.spacingM,
      ),
      height: cardHeight,
      child: Stack(
        children: [
          // Slideshow
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onSlideChanged,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildSlideshowItem(context, index, cardHeight);
            },
          ),
          // Page indicators at bottom
          Positioned(
            bottom: AppTheme.spacingM,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: _currentSlideIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentSlideIndex == index
                        ? AppTheme.surfaceColor
                        : AppTheme.surfaceColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideshowItem(BuildContext context, int index, double height) {
    // Beautiful gradient backgrounds for each slide
    final gradients = [
      [
        Color.fromARGB(255, 18, 42, 68), // Dark blue (#122A44)
        Color.fromARGB(255, 31, 64, 100), // Medium blue
        Color.fromARGB(255, 23, 52, 84), // Accent blue
      ],
      [
        Color.fromARGB(255, 23, 52, 84), // Accent blue (#173454)
        Color.fromARGB(255, 35, 70, 110), // Lighter blue
        Color.fromARGB(255, 18, 42, 68), // Dark blue
      ],
      [
        Color.fromARGB(255, 31, 64, 100), // Medium blue
        Color.fromARGB(255, 18, 42, 68), // Dark blue
        Color.fromARGB(255, 28, 56, 88), // Medium dark blue
      ],
    ];

    final icons = [
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.savings,
    ];

    final titles = [
      'គណនី',
      'កាត',
      'រក្សាទុក',
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: Color.fromARGB(255, 66, 129, 177), // Border color (#4281B1)
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradients[index],
                ),
              ),
            ),
            // Optional: You can add network images here if needed
            // Image.network(
            //   imageUrls[index],
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) => SizedBox(),
            // ),
            // Icon and title in center (optional decorative element)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icons[index],
                      color: AppTheme.surfaceColor.withOpacity(0.6),
                      size: MediaQuery.of(context).size.width * 0.12,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  Text(
                    titles[index],
                    style: TextStyle(
                      color: AppTheme.surfaceColor.withOpacity(0.7),
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          SizedBox(height: AppTheme.spacingM),
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Exchange rate card
          Expanded(
            child: _buildExploreServiceCard(
              context,
              icon: Icons.book,
              label: 'Exchange',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExchangeRateScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: AppTheme.spacingM),
          // Report card
          Expanded(
            child: _buildExploreServiceCard(
              context,
              icon: Icons.local_offer,
              label: 'Report',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreServiceCard(
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
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.cardGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color:
                  Color.fromARGB(255, 66, 129, 177), // Border color (#4281B1)
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.surfaceColor,
                  size: 22,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
