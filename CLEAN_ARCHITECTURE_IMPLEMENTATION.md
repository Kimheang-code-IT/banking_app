# Clean Architecture Banking App Implementation

## Overview
This document describes the clean architecture implementation of the banking app with Riverpod state management, go_router navigation, and comprehensive localization.

## Project Structure

```
lib/
├── app/                          # App-level configuration
│   ├── router/                   # go_router configuration
│   │   └── app_router.dart
│   ├── theme/                    # App theme
│   │   └── app_theme.dart
│   ├── l10n/                     # Localization
│   │   └── app_localizations.dart
│   ├── main_app.dart             # Main app widget
│   └── providers/                # Re-exports
│
├── core/                         # Shared core functionality
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   └── app_exceptions.dart
│   ├── widgets/                  # Reusable widgets
│   │   ├── primary_button.dart
│   │   ├── app_text_field.dart
│   │   └── section_title.dart
│   └── helpers/
│       └── validation_helper.dart
│
├── features/                     # Feature modules
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── welcome_screen.dart
│   │       │   └── language_picker_screen.dart
│   │       └── providers/
│   │           └── locale_provider.dart
│   │
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── auth_result.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_mock.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_flow/
│   │       │       ├── scan_id_screen.dart
│   │       │       ├── verify_data_screen.dart
│   │       │       └── set_password_screen.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── kyc/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── kyc_data.dart
│   │   │   └── repositories/
│   │   │       └── kyc_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── kyc_repository_mock.dart
│   │   └── presentation/
│   │       └── providers/
│   │           └── kyc_provider.dart
│   │
│   └── dashboard/
│       └── presentation/
│           └── screens/
│               └── dashboard_screen.dart
│
├── l10n/                         # ARB localization files
│   ├── app_en.arb
│   └── app_km.arb
│
└── main.dart                     # Entry point (existing)
    main_new.dart                  # New entry point (optional)
```

## Key Features Implemented

### 1. Clean Architecture
- **Domain Layer**: Entities and repository interfaces
- **Data Layer**: Mock repository implementations with clear TODOs for API integration
- **Presentation Layer**: Screens, widgets, and Riverpod providers

### 2. State Management (Riverpod)
- `LocaleProvider`: Manages app locale with persistence
- `AuthProvider`: Handles authentication state
- `KycProvider`: Manages KYC flow state

### 3. Navigation (go_router)
- Declarative routing with authentication guards
- Named routes for type-safe navigation
- Automatic redirects based on auth state

### 4. Localization
- Full English and Khmer (ភាសាខ្មែរ) support
- ARB files for translation management
- Locale persistence in SharedPreferences

### 5. Screen Flow
1. **Welcome Screen**: Animated intro with "Get Started" button
2. **Language Picker**: Select English/Khmer, persists choice
3. **Login Screen**: Email/password with validation
4. **Sign Up Flow**:
   - Scan ID (mock with "Use Sample Data" option)
   - Verify Data (editable form)
   - Set Password
5. **Dashboard**: Simple banking dashboard with logout

## Dependencies Added

```yaml
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.3
go_router: ^13.0.0
build_runner: ^2.4.8 (dev)
riverpod_generator: ^2.3.9 (dev)
```

## Usage

### Running the New Architecture

Option 1: Update existing main.dart
```dart
// Replace lib/main.dart content with:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/main_app.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}
```

Option 2: Use main_new.dart temporarily
```bash
flutter run -t lib/main_new.dart
```

### Demo Credentials
- Email: `demo@bank.com`
- Password: `Password123`

### Testing
```bash
flutter test
```

## API Integration TODOs

### AuthRepository
- [ ] Replace `AuthRepositoryMock` with `AuthRepositoryImpl`
- [ ] Add Dio/Retrofit client
- [ ] Implement real login endpoint: `POST /auth/login`
- [ ] Implement real register endpoint: `POST /auth/register`
- [ ] Add token refresh logic
- [ ] Store tokens in flutter_secure_storage

### KycRepository
- [ ] Replace `KycRepositoryMock` with real ID scanning
- [ ] Integrate camera/ML kit for ID card scanning
- [ ] Implement OCR for data extraction
- [ ] Add image upload endpoint: `POST /kyc/upload`

## Files Created

### Core (7 files)
- `lib/core/constants/app_constants.dart`
- `lib/core/errors/app_exceptions.dart`
- `lib/core/widgets/primary_button.dart`
- `lib/core/widgets/app_text_field.dart`
- `lib/core/widgets/section_title.dart`
- `lib/core/helpers/validation_helper.dart`

### Domain (4 files)
- `lib/features/auth/domain/entities/auth_result.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/kyc/domain/entities/kyc_data.dart`
- `lib/features/kyc/domain/repositories/kyc_repository.dart`

### Data (2 files)
- `lib/features/auth/data/repositories/auth_repository_mock.dart`
- `lib/features/kyc/data/repositories/kyc_repository_mock.dart`

### Presentation (10 files)
- `lib/features/onboarding/presentation/providers/locale_provider.dart`
- `lib/features/onboarding/presentation/screens/welcome_screen.dart`
- `lib/features/onboarding/presentation/screens/language_picker_screen.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/signup_flow/scan_id_screen.dart`
- `lib/features/auth/presentation/screens/signup_flow/verify_data_screen.dart`
- `lib/features/auth/presentation/screens/signup_flow/set_password_screen.dart`
- `lib/features/kyc/presentation/providers/kyc_provider.dart`
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

### App (4 files)
- `lib/app/router/app_router.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/l10n/app_localizations.dart`
- `lib/app/main_app.dart`

### Localization (3 files)
- `lib/l10n/app_en.arb`
- `lib/l10n/app_km.arb`
- `l10n.yaml`

### Tests (2 files)
- `test/features/auth/data/repositories/auth_repository_mock_test.dart`
- `test/features/onboarding/presentation/providers/locale_provider_test.dart`

## Migration Notes

The new architecture runs alongside the existing Provider-based code. To fully migrate:

1. Update `lib/main.dart` to use `MainApp` and `ProviderScope`
2. Gradually migrate existing screens to new structure
3. Replace Provider providers with Riverpod providers
4. Update navigation calls to use `context.go()` instead of `Navigator.push()`

## Next Steps

1. Run `flutter pub get` to install new dependencies
2. Run `flutter gen-l10n` to generate localization files (if using ARB generation)
3. Test the app flow: Welcome → Language → Login → Dashboard
4. Test registration flow: Sign Up → Scan ID → Verify → Set Password → Login
5. Integrate real API endpoints when backend is ready

