// Defines colors used throughout the app
import 'package:flutter/material.dart';

class AppColors {
  static bool _isDarkMode = false;

  // Method to update the theme mode
  static void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
  }

  // --- Light Theme Colors (Material Purple) ---
  static const Color _lightBackground = Color(0xFFF5F5F5);
  static const Color _lightCardBackground = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF673AB7); // Material Purple Primary
  static const Color _lightPrimaryVariant = Color(0xFF512DA8); // Material Purple Primary Variant
  static const Color _lightSecondary = Color(0xFF03DAC6); // Material Teal Secondary
  static const Color _lightSecondaryVariant = Color(0xFF018786); // Material Teal Secondary Variant
  static const Color _lightTextDark = Color(0xFF000000);
  static final Color _lightDivider = const Color(0xFFBDBDBD).withAlpha(80);

  // --- Dark Theme Colors (Material Dark Purple) ---
  static const Color _darkBackground = Color(0xFF121212); // Material Dark Background
  static const Color _darkCardBackground = Color(0xFF1E1E1E); // Slightly lighter surface
  static const Color _darkPrimary = Color(0xFFBB86FC); // Material Dark Purple Primary
  static const Color _darkPrimaryVariant = Color(0xFF512DA8); // Same as light theme
  static const Color _darkSecondary = Color(0xFF03DAC6); // Material Teal Secondary
  static const Color _darkTextLight = Color(0xDEFFFFFF); // 87% white
  static final Color _darkDivider = const Color(0x99FFFFFF).withAlpha(40); // 40% white

  // --- Accent Colors from Purple Scale ---
  static const Color _purpleAccent = Color(0xFFE040FB); // Purple A200
  static const Color _errorLight = Color(0xFFB00020); // Material Design error (light)
  static const Color _errorDark = Color(0xFFCF6679); // Material Design error (dark)

  // --- General App Colors ---

  // Primary colors
  static Color get primary => _isDarkMode ? _darkPrimary : _lightPrimary;
  static Color get primaryVariant => _isDarkMode ? _darkPrimaryVariant : _lightPrimaryVariant;
  static Color get secondary => _isDarkMode ? _darkSecondary : _lightSecondary;
  static Color get secondaryVariant => _isDarkMode ? _darkSecondary : _lightSecondaryVariant;
  static Color get background => _isDarkMode ? _darkBackground : _lightBackground;
  static Color get accent => _isDarkMode ? _purpleAccent : _purpleAccent;
  static Color get cardBackground => _isDarkMode ? _darkCardBackground : _lightCardBackground;

  // Success and Error (can remain the same or be themed)
  static Color get success => Colors.green.shade400;
  static Color get error => _isDarkMode ? _errorDark : _errorLight;
  static Color get danger => error; // Alias for error

  // Text colors
  static Color get textDark => _isDarkMode ? _darkTextLight : _lightTextDark;
  static Color get textLight => _isDarkMode ? const Color(0xDEFFFFFF) : Colors.white; // 87% white in dark mode
  static Color get textMuted => _isDarkMode 
      ? const Color(0x99FFFFFF) // 60% white - medium emphasis
      : const Color(0x99000000); // 60% black
  static Color get textDisabled => _isDarkMode 
      ? const Color(0x61FFFFFF) // 38% white 
      : const Color(0x61000000); // 38% black

  // UI Element colors
  static Color get divider => _isDarkMode ? _darkDivider : _lightDivider;
  static Color get shadow => _isDarkMode 
      ? Colors.black.withAlpha(30) 
      : Colors.black.withAlpha(20);
                             
  // Favorite/Star color - using a complementary color to the purple theme
  static Color get starYellow => const Color(0xFFFFC107); // Amber 500
  
  // Helper method to get Material purple shade from full scale
  static Color getPurpleShade(int shade) {
    switch (shade) {
      case 50: return const Color(0xFFF3E5F5);
      case 100: return const Color(0xFFE1BEE7);
      case 200: return const Color(0xFFCE93D8);
      case 300: return const Color(0xFFBA68C8);
      case 400: return const Color(0xFFAB47BC);
      case 500: return const Color(0xFF9C27B0);
      case 600: return const Color(0xFF8E24AA);
      case 700: return const Color(0xFF7B1FA2);
      case 800: return const Color(0xFF6A1B9A);
      case 900: return const Color(0xFF4A148C);
      default: return const Color(0xFF9C27B0); // Default to 500
    }
  }
  
  // Helper method to get Material purple accent from full scale
  static Color getPurpleAccent(int accentValue) {
    switch (accentValue) {
      case 100: return const Color(0xFFEA80FC);
      case 200: return const Color(0xFFE040FB);
      case 400: return const Color(0xFFD500F9);
      case 700: return const Color(0xFFAA00FF);
      default: return const Color(0xFFE040FB); // Default to A200
    }
  }
}