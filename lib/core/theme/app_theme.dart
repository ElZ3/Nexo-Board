import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const primaryColor = Color(0xFF6200EE);
    const scaffoldBackground = Color(0xFF151515);
    const cardBackground = Color(0xFF222222);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamilyFallback: const ['Roboto'],
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: primaryColor,
      cardColor: cardBackground,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'CyGrotesk',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'CyGrotesk',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontFamily: 'CyGrotesk',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Lovera',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Lovera',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Lovera',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white38,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Lovera',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.red,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Lovera',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Lovera',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 54),
          textStyle: const TextStyle(
            fontFamily: 'Lovera',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
