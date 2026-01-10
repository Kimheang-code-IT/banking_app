import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banking_app/features/onboarding/presentation/providers/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should default to English locale', () async {
      final container = ProviderContainer();
      final locale = container.read(localeProvider);

      expect(locale.languageCode, 'en');
      container.dispose();
    });

    test('should change locale when setLocale is called', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('km'));
      final locale = container.read(localeProvider);

      expect(locale.languageCode, 'km');
      container.dispose();
    });

    test('should persist locale in SharedPreferences', () async {
      final container = ProviderContainer();
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('km'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), 'km');
      container.dispose();
    });
  });
}

