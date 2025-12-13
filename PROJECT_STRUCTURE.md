# Banking App - Project Structure

## Cleaned Project Structure

### 📁 lib/
```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── account.dart
│   ├── bill.dart
│   ├── card.dart
│   ├── transaction.dart
│   └── user.dart
├── providers/                         # State management (Provider pattern)
│   ├── account_provider.dart
│   ├── auth_provider.dart
│   ├── bill_provider.dart
│   ├── card_provider.dart
│   ├── currency_provider.dart
│   └── transaction_provider.dart
├── screens/                           # UI Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── bills/
│   │   └── bills_screen.dart
│   ├── cards/
│   │   └── cards_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── deposit/
│   │   └── deposit_screen.dart
│   ├── ecard/
│   │   └── ecard_screen.dart
│   ├── exchange_rate/
│   │   └── exchange_rate_screen.dart
│   ├── messages/
│   │   └── messages_screen.dart
│   ├── note/
│   │   └── note_screen.dart
│   ├── notification/
│   │   └── notification_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── qr_scanner/
│   │   └── qr_scanner_screen.dart
│   ├── report/
│   │   └── report_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   ├── transfer/
│   │   └── transfer_screen.dart
│   ├── welcome/
│   │   └── welcome_screen.dart
│   ├── withdraw/
│   │   └── withdraw_screen.dart
│   └── main_screen.dart               # Main navigation screen
├── services/                          # Business logic services
│   ├── auth_service.dart
│   ├── currency_service.dart
│   ├── mock_data_service.dart
│   └── storage_service.dart
├── theme/                             # App theming
│   └── app_theme.dart
└── widgets/                           # Reusable widgets
    ├── account_card.dart
    ├── bottom_navigation_widget.dart
    ├── card_widget.dart
    ├── currency_converter.dart
    ├── custom_button.dart
    └── transaction_item.dart
```

## Removed Files

### ❌ Unused Screens (Removed)
- `lib/screens/buy_data/buy_data_screen.dart` - Replaced with ECardScreen
- `lib/screens/card_expert/card_expert_screen.dart` - Not used
- `lib/screens/transactions/transactions_screen.dart` - Not used

### ❌ Unused Dependencies (Removed from pubspec.yaml)
- `go_router: ^13.0.0` - Not used (using MaterialPageRoute instead)
- `shimmer: ^3.0.0` - Not used

## Active Screens

### Main Navigation (Bottom Navigation Bar)
1. **Home** - DashboardScreen
2. **Messages** - MessagesScreen
3. **Notes** - NoteScreen
4. **Settings** - SettingsScreen

### Feature Screens (Accessible from Dashboard)
- Notification
- Scan QR Code
- Profile
- Deposit
- Cards
- Withdraw
- Transfer
- E-card
- Report
- Exchange Rate

### Other Screens
- Login/Signup (Auth)
- Welcome (First-time user)
- Bills (Available but not in main navigation)

## Dependencies

### Active Dependencies
- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Local storage
- `intl: ^0.19.0` - Date/number formatting
- `mobile_scanner: ^4.0.0` - QR code scanning

## Notes

- All screens now have consistent app bar (60px height, back icon left, title center, logo right)
- All screens have bottom navigation bar for easy navigation
- Project structure follows Flutter best practices
- No unused imports or dead code

