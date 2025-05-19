import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3); // Modern Blue
  static const Color secondaryColor = Color(0xFF03A9F4); // Light Blue
  static const Color accentColor = Color(0xFF00BCD4); // Cyan

  // Success Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color successLightColor = Color(0xFF81C784); // Light Green

  // Error Colors
  static const Color errorColor = Color(0xFFE53935); // Red
  static const Color errorLightColor = Color(0xFFEF5350); // Light Red

  // Warning Colors
  static const Color warningColor = Color(0xFFFFA726); // Orange
  static const Color warningLightColor = Color(0xFFFFB74D); // Light Orange

  // Neutral Colors
  static const Color neutralColor = Color(0xFF607D8B); // Blue Grey
  static const Color neutralLightColor = Color(0xFF90A4AE); // Light Blue Grey

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121); // Dark Grey
  static const Color textSecondaryColor = Color(0xFF757575); // Medium Grey
  static const Color textHintColor = Color(0xFFBDBDBD); // Light Grey

  // Dark Text Colors
  static const Color darkTextColor = Color(0xFFE0E0E0); // Light Grey
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0); // Lighter Grey

  // Light Text Colors
  static const Color lightTextColor = Color(0xFF212121); // Dark Grey
  static const Color lightSecondaryTextColor = Color(0xFF757575); // Medium Grey

  // Background Gradients
  static const List<Color> lightGradient = [
    Color(0xFFF5F5F5), // Light Grey
    Color(0xFFFFFFFF), // White
  ];

  static const List<Color> darkGradient = [
    Color(0xFF121212), // Dark Grey
    Color(0xFF1E1E1E), // Darker Grey
  ];

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3), // Modern Blue
    Color(0xFF03A9F4), // Light Blue
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFF4DD0E1), // Light Cyan
  ];

  static const List<Color> accentGradient = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFF4DD0E1), // Light Cyan
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50), // Green
    Color(0xFF81C784), // Light Green
  ];

  static const List<Color> errorGradient = [
    Color(0xFFE53935), // Red
    Color(0xFFEF5350), // Light Red
  ];

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212); // Dark Grey
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Darker Grey
  static const Color darkCardColor = Color(0xFF2D2D2D); // Dark Card

  static const List<Color> darkPrimaryGradient = [
    Color(0xFF1565C0), // Dark Blue
    Color(0xFF1976D2), // Medium Blue
  ];

  static const List<Color> darkSecondaryGradient = [
    Color(0xFF00838F), // Dark Cyan
    Color(0xFF0097A7), // Medium Cyan
  ];

  static const List<Color> darkAccentGradient = [
    Color(0xFF00838F), // Dark Cyan
    Color(0xFF0097A7), // Medium Cyan
  ];

  // App Bar Gradients
  static const List<Color> lightAppBarGradient = [
    Color(0xFF2196F3), // Modern Blue
    Color(0xFF03A9F4), // Light Blue
  ];

  static const List<Color> darkAppBarGradient = [
    Color(0xFF1565C0), // Dark Blue
    Color(0xFF1976D2), // Medium Blue
  ];

  // Card Gradients
  static const List<Color> lightCardGradient = [
    Color(0xFFFFFFFF), // White
    Color(0xFFF5F5F5), // Light Grey
  ];

  static const List<Color> darkCardGradient = [
    Color(0xFF2D2D2D), // Dark Card
    Color(0xFF1E1E1E), // Darker Grey
  ];

  // Button Gradients
  static const List<Color> primaryButtonGradient = [
    Color(0xFF2196F3), // Modern Blue
    Color(0xFF03A9F4), // Light Blue
  ];

  static const List<Color> secondaryButtonGradient = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFF4DD0E1), // Light Cyan
  ];

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000); // 10% Black
  static const Color darkShadowColor = Color(0x33000000); // 20% Black

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0); // Light Grey
  static const Color darkBorderColor = Color(0xFF424242); // Dark Grey

  // Overlay Colors
  static const Color overlayColor = Color(0x80000000); // 50% Black
  static const Color darkOverlayColor = Color(0xCC000000); // 80% Black

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Elevation
  static const double smallElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double largeElevation = 8.0;
  static const double extraLargeElevation = 16.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Icon Sizes
  static const double smallIcon = 16.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;

  // Font Sizes
  static const double smallFont = 12.0;
  static const double mediumFont = 14.0;
  static const double largeFont = 16.0;
  static const double extraLargeFont = 20.0;
  static const double titleFont = 24.0;
  static const double headlineFont = 32.0;

  // Font Weights
  static const FontWeight lightWeight = FontWeight.w300;
  static const FontWeight regularWeight = FontWeight.w400;
  static const FontWeight mediumWeight = FontWeight.w500;
  static const FontWeight semiBoldWeight = FontWeight.w600;
  static const FontWeight boldWeight = FontWeight.w700;

  // Letter Spacing
  static const double tightSpacing = -0.5;
  static const double normalSpacing = 0.0;
  static const double wideSpacing = 0.5;
  static const double extraWideSpacing = 1.0;

  // Line Height
  static const double tightHeight = 1.0;
  static const double normalHeight = 1.2;
  static const double wideHeight = 1.5;
  static const double extraWideHeight = 2.0;

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onBackground: textPrimaryColor,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimaryColor),
      displayMedium: TextStyle(color: textPrimaryColor),
      displaySmall: TextStyle(color: textPrimaryColor),
      headlineLarge: TextStyle(color: textPrimaryColor),
      headlineMedium: TextStyle(color: textPrimaryColor),
      headlineSmall: TextStyle(color: textPrimaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
      titleSmall: TextStyle(color: textPrimaryColor),
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      bodySmall: TextStyle(color: textSecondaryColor),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurfaceColor,
      background: darkBackgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextColor,
      onBackground: darkTextColor,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkTextColor),
      displayMedium: TextStyle(color: darkTextColor),
      displaySmall: TextStyle(color: darkTextColor),
      headlineLarge: TextStyle(color: darkTextColor),
      headlineMedium: TextStyle(color: darkTextColor),
      headlineSmall: TextStyle(color: darkTextColor),
      titleLarge: TextStyle(color: darkTextColor),
      titleMedium: TextStyle(color: darkTextColor),
      titleSmall: TextStyle(color: darkTextColor),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkSecondaryTextColor),
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
    ),
  );
} 