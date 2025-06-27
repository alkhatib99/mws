import 'package:flutter/material.dart';

class AppTheme {
  // Colors from the original Python app
  static const Color primaryBackground = Color(0xFF1E1E2F);
  static const Color primaryGreen = Color(0xFF28A745);
  static const Color primaryBlue = Color(0xFF007ACC);
  static const Color neutralGray = Color(0xFF44475A);
  static const Color lightBackground = Color(0xFFF0F0F0);
  static const Color textFieldBackground = Color(0xFFFAFAFA);
  static const Color whiteText = Colors.white;
  static const Color lightGrayText = Color(0xFFD3D3D3);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryBlue,
        surface: primaryBackground,
        background: primaryBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: whiteText,
        onBackground: whiteText,
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
          fontFamily: 'Arial',
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: whiteText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
        headlineMedium: TextStyle(
          color: whiteText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
        titleLarge: TextStyle(
          color: whiteText,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
        bodyLarge: TextStyle(
          color: whiteText,
          fontSize: 14,
          fontFamily: 'Arial',
        ),
        bodyMedium: TextStyle(
          color: whiteText,
          fontSize: 12,
          fontFamily: 'Arial',
        ),
        labelLarge: TextStyle(
          color: whiteText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Arial',
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontFamily: 'Arial',
        ),
        labelStyle: const TextStyle(
          color: whiteText,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: primaryBlue),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: neutralGray,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),

      // Dropdown Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Arial',
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: neutralGray,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  // Custom button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: 'Arial',
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: 'Arial',
    ),
  );

  static ButtonStyle get neutralButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: neutralGray,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: 'Arial',
    ),
  );
}

