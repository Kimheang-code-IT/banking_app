import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/card_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/currency_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/storage_service.dart';

void main() {
  // Initialize date formatting
  Intl.defaultLocale = 'en_US';
  
  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: MaterialApp(
        title: 'Banking App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;
  bool _showWelcome = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;
    
    // Check if welcome screen should be shown
    final showWelcome = !(await _storageService.isWelcomeScreenShown());
    
    if (showWelcome) {
      if (!mounted) return;
      setState(() {
        _showWelcome = true;
        _isInitializing = false;
      });
      return;
    }
    
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    
    // Load data if authenticated
    if (authProvider.isAuthenticated) {
      if (!mounted) return;
      await Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      if (!mounted) return;
      await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
      if (!mounted) return;
      await Provider.of<CardProvider>(context, listen: false).loadCards();
      if (!mounted) return;
      await Provider.of<BillProvider>(context, listen: false).loadBills();
      if (!mounted) return;
      await Provider.of<CurrencyProvider>(context, listen: false).loadPreferences();
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentOrange,
                AppTheme.accentOrange,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (_showWelcome) {
      return const WelcomeScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
