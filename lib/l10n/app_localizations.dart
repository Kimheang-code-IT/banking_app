import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'GEN-Z BANK',
      'welcome': 'Welcome',
      'welcome_back': 'Welcome back',
      'select_language': 'Select Language',
      'continue': 'Continue',

      // Auth
      'login': 'Log In',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'name': 'Full Name',
      'phone': 'Phone Number',
      'confirm_password': 'Confirm Password',
      'agree_terms': 'I agree to the Terms & Conditions',
      'open_account': 'Open an Account',
      'reset_password': 'Reset Password',
      'send_reset_code': 'Send Reset Code',

      // Dashboard
      'hello': 'Hello',
      'view_profile': 'View Profile',
      'total_balance': 'Total Balance',
      'account': 'Account',
      'deposit': 'Deposit',
      'withdraw': 'Withdraw',
      'transfer': 'Transfer',
      'payment': 'Payment',
      'cards': 'Cards',
      'scan_qr': 'Scan QR',
      'transfers': 'Transfers',
      'exchange_rate': 'Exchange Rate',
      'report': 'Report',

      // Transactions
      'current_balance': 'Current Balance',
      'total_deposits': 'Total Deposits',
      'deposit_count': 'Deposit Count',
      'total_withdrawals': 'Total Withdrawals',
      'withdrawal_count': 'Withdrawal Count',
      'no_deposit_history': 'No deposit history',
      'no_withdrawal_history': 'No withdrawal history',
      'deposit_history': 'Deposit History',
      'withdrawal_history': 'Withdrawal History',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'settings': 'Settings',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'messages': 'Messages',
      'notes': 'Notes',
      'bills': 'Bills',
      'ecard': 'E-Card',
      'logout': 'Logout',
      'language': 'Language',
      'english': 'English',
      'khmer': 'ភាសាខ្មែរ',
    },
    'km': {
      // App
      'app_name': 'ធនាគារ GEN-Z',
      'welcome': 'សូមស្វាគមន៍',
      'welcome_back': 'សូមស្វាគមន៍មកវិញ',
      'select_language': 'ជ្រើសរើសភាសា',
      'continue': 'បន្ត',

      // Auth
      'login': 'ចូល',
      'signup': 'ចុះឈ្មោះ',
      'email': 'អ៊ីមែល',
      'password': 'ពាក្យសម្ងាត់',
      'forgot_password': 'ភ្លេចពាក្យសម្ងាត់?',
      'name': 'ឈ្មោះពេញ',
      'phone': 'លេខទូរស័ព្ទ',
      'confirm_password': 'បញ្ជាក់ពាក្យសម្ងាត់',
      'agree_terms': 'ខ្ញុំយល់ព្រមនឹងលក្ខខណ្ឌ',
      'open_account': 'បើកគណនី',
      'reset_password': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
      'send_reset_code': 'ផ្ញើលេខកូដ',

      // Dashboard
      'hello': 'សួស្តី',
      'view_profile': 'មើលប្រូហ្វាល',
      'total_balance': 'សមតុល្យសរុប',
      'account': 'គណនី',
      'deposit': 'ដាក់ប្រាក់',
      'withdraw': 'ដកប្រាក់',
      'transfer': 'ផ្ទេរ',
      'payment': 'បង់ប្រាក់',
      'cards': 'កាត',
      'scan_qr': 'ស្កេន QR',
      'transfers': 'ការផ្ទេរ',
      'exchange_rate': 'អត្រាប្តូរប្រាក់',
      'report': 'របាយការណ៍',

      // Transactions
      'current_balance': 'សមតុល្យបច្ចុប្បន្ន',
      'total_deposits': 'ការដាក់ប្រាក់សរុប',
      'deposit_count': 'ចំនួនការដាក់ប្រាក់',
      'total_withdrawals': 'ការដកប្រាក់សរុប',
      'withdrawal_count': 'ចំនួនការដកប្រាក់',
      'no_deposit_history': 'មិនមានប្រវត្តិការដាក់ប្រាក់',
      'no_withdrawal_history': 'មិនមានប្រវត្តិការដកប្រាក់',
      'deposit_history': 'ប្រវត្តិការដាក់ប្រាក់',
      'withdrawal_history': 'ប្រវត្តិការដកប្រាក់',

      // Common
      'save': 'រក្សាទុក',
      'cancel': 'បោះបង់',
      'confirm': 'បញ្ជាក់',
      'delete': 'លុប',
      'edit': 'កែប្រែ',
      'search': 'ស្វែងរក',
      'settings': 'ការកំណត់',
      'profile': 'ប្រូហ្វាល',
      'notifications': 'ការជូនដំណឹង',
      'messages': 'សារ',
      'notes': 'កំណត់ចំណាំ',
      'bills': 'វិក្កយបត្រ',
      'ecard': 'កាតអេឡិចត្រូនិច',
      'logout': 'ចេញ',
      'language': 'ភាសា',
      'english': 'English',
      'khmer': 'ភាសាខ្មែរ',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get welcomeBack => translate('welcome_back');
  String get selectLanguage => translate('select_language');
  String get continueText => translate('continue');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get confirmPassword => translate('confirm_password');
  String get agreeTerms => translate('agree_terms');
  String get openAccount => translate('open_account');
  String get resetPassword => translate('reset_password');
  String get sendResetCode => translate('send_reset_code');
  String get hello => translate('hello');
  String get viewProfile => translate('view_profile');
  String get totalBalance => translate('total_balance');
  String get account => translate('account');
  String get deposit => translate('deposit');
  String get withdraw => translate('withdraw');
  String get transfer => translate('transfer');
  String get payment => translate('payment');
  String get cards => translate('cards');
  String get scanQr => translate('scan_qr');
  String get transfers => translate('transfers');
  String get exchangeRate => translate('exchange_rate');
  String get report => translate('report');
  String get currentBalance => translate('current_balance');
  String get totalDeposits => translate('total_deposits');
  String get depositCount => translate('deposit_count');
  String get totalWithdrawals => translate('total_withdrawals');
  String get withdrawalCount => translate('withdrawal_count');
  String get noDepositHistory => translate('no_deposit_history');
  String get noWithdrawalHistory => translate('no_withdrawal_history');
  String get depositHistory => translate('deposit_history');
  String get withdrawalHistory => translate('withdrawal_history');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get messages => translate('messages');
  String get notes => translate('notes');
  String get bills => translate('bills');
  String get ecard => translate('ecard');
  String get logout => translate('logout');
  String get language => translate('language');
  String get english => translate('english');
  String get khmer => translate('khmer');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'km'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
