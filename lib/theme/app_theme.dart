import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color accentOrange =
      Color.fromARGB(255, 23, 52, 84); // App bar color - Blue (#173454)
  static const Color cardIconColor =
      Color.fromARGB(255, 255, 255, 255); // Card icon color - White (#FFFFFF)

  // Background Colors
  static const Color lightBackground =
      Color.fromARGB(255, 255, 255, 255); // Page background - White
  static const Color cardGray =
      Color.fromARGB(255, 18, 42, 68); // Card background - Dark blue (#122A44)
  static const Color cardGradientStart =
      Color.fromARGB(255, 173, 216, 255); // Light blue gradient start (#ADD8FF)
  static const Color cardGradientEnd =
      Color.fromARGB(255, 255, 255, 255); // White gradient end
  static const Color surfaceColor = Color.fromARGB(
      255, 248, 249, 250); // Surface color - Light gray (#F8F9FA)

  // Text Colors
  static const Color textPrimary = Color.fromARGB(
      255, 248, 249, 250); // Primary text on dark bg - White (#F8F9FA)
  static const Color textSecondary = Color.fromARGB(
      255, 248, 249, 250); // Secondary text on dark bg - White (#F8F9FA)
  static const Color textTertiary =
      Color.fromARGB(255, 180, 180, 180); // Tertiary text - Lighter gray
  static const Color textOnLight = Color.fromARGB(
      255, 28, 28, 29); // Text on white/light bg - Dark gray (#1C1C1D)
  static const Color textSecondaryOnLight = Color.fromARGB(
      255, 96, 96, 96); // Secondary text on light bg - Gray (#606060)

  // Status Colors
  static const Color successGreen =
      Color.fromARGB(255, 34, 197, 94); // Success - Green (#22C55E)
  static const Color errorRed =
      Color.fromARGB(255, 239, 68, 68); // Error - Red (#EF4444)
  static const Color warningYellow =
      Color.fromARGB(255, 251, 191, 36); // Warning - Yellow (#FBBF24)
  static const Color infoBlue =
      Color.fromARGB(255, 59, 130, 246); // Info - Blue (#3B82F6)

  // Border & Divider Colors
  static const Color borderLight =
      Color.fromARGB(255, 17, 89, 132); // Card border - Blue (#115984)
  static const Color dividerColor =
      Color.fromARGB(255, 229, 231, 235); // Divider color (#E5E7EB)

  // Navigation Button Colors
  static const Color navButtonTop = Color.fromARGB(
      255, 21, 47, 75); // Navigation button top - Dark blue (#152F4B)
  static const Color navButtonBottom = Color.fromARGB(
      255, 31, 64, 100); // Navigation button bottom - Dark blue (#1F4064)

  // Spacing Constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Elevation/Shadow Constants
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 12.0;

  // Border Radius Constants
  static const double radiusXS = 6.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentOrange,
        primary: accentOrange,
        secondary: accentOrange,
        surface: surfaceColor,
        background: lightBackground,
        error: textSecondary,
        onPrimary: surfaceColor,
        onSecondary: surfaceColor,
        onSurface: textOnLight,
        onBackground: textOnLight,
        onError: surfaceColor,
        primaryContainer: lightBackground,
        secondaryContainer: lightBackground,
        errorContainer: lightBackground,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: accentOrange, // Blue color - different from cardGray
        foregroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: surfaceColor,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(color: surfaceColor),
      ),
      cardTheme: CardTheme(
        color: cardGray, // Dark blue card background (#122A44)
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(
            color: borderLight,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: spacingM, vertical: spacingS),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: surfaceColor,
          padding: const EdgeInsets.symmetric(
              horizontal: spacingXL, vertical: spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          elevation: elevationLow,
          shadowColor: accentOrange.withOpacity(0.3),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentOrange,
          side: const BorderSide(color: accentOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(
              horizontal: spacingXL, vertical: spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentOrange,
          padding: const EdgeInsets.symmetric(
              horizontal: spacingM, vertical: spacingS),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: accentOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: textSecondary, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: textSecondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingM, vertical: spacingM),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: textSecondaryOnLight,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: textSecondaryOnLight,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textOnLight,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textOnLight,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textOnLight,
          letterSpacing: 0,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textOnLight,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textOnLight,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textOnLight,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textOnLight,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textOnLight,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnLight,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textOnLight,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textOnLight,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondaryOnLight,
          letterSpacing: 0.4,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnLight,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textOnLight,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryOnLight,
          letterSpacing: 0.5,
          height: 1.4,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentOrange,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: elevationHigh,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: surfaceColor,
        elevation: elevationMedium,
        shape: CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightBackground,
        selectedColor: accentOrange,
        disabledColor: textSecondary.withOpacity(0.1),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: surfaceColor,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: spacingM, vertical: spacingS),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Helper method for consistent shadows
  static List<BoxShadow> getCardShadow({double opacity = 0.08}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 10,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> getElevatedShadow({double opacity = 0.12}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }
}
