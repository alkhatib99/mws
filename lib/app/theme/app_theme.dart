import 'package:flutter/material.dart';

class AppTheme {
  // Colors inspired by dapp.bagguild.com
  static const Color primaryBackground = Color(0xFF1A0A2E); // Dark purple/black
  static const Color primaryAccent = Color(0xFF8A2BE2); // Vibrant purple
  static const Color primaryBlue = Color(0xFF1E90FF); // Bright blue accent
  static const Color primaryGreen = Color(0xFF32CD32); // Bright green accent
  static const Color secondaryAccent = Color(0xFF00FF00); // Green accent
  static const Color goldAccent = Color(0xFFFFD700); // Gold accent
  static const Color neutralGray = Color(0xFF44475A);
  static const Color textFieldBackground =
      Color(0xFF2C1A40); // Slightly lighter than primaryBackground
  static const Color whiteText = Colors.white;
  static const Color lightGrayText = Color(0xFFD3D3D3);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: primaryBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: whiteText,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        foregroundColor: whiteText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: whiteText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat', // Changed font
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: whiteText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        headlineMedium: TextStyle(
          color: whiteText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        titleLarge: TextStyle(
          color: whiteText,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        bodyLarge: TextStyle(
          color: whiteText,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
        bodyMedium: TextStyle(
          color: whiteText,
          fontSize: 12,
          fontFamily: 'Montserrat',
        ),
        labelLarge: TextStyle(
          color: whiteText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: textFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // More rounded corners
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
        labelStyle: const TextStyle(
          color: whiteText,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent, // Use primaryAccent for main buttons
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // More rounded corners
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparent background
          foregroundColor: primaryAccent, // Accent color for text/icon
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side:
              const BorderSide(color: primaryAccent, width: 2), // Accent border
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparent background
          foregroundColor: lightGrayText, // Light gray for text
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),

      // Dropdown Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: textFieldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textStyle: const TextStyle(
          color: whiteText,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: textFieldBackground, // Use a darker background for cards
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // More rounded corners for cards
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  // Custom button styles (updated to reflect new theme)
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryAccent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryAccent, width: 2),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      );

  static ButtonStyle get neutralButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: neutralGray,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      );
}
