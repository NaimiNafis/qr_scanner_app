// Defines colors used throughout the app
import 'package:flutter/material.dart';

class AppColors {
  static bool _isDarkMode = false;

  // Method to update the theme mode
  static void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
  }

  // --- Light Mode Colors (Cool Gray Palette) ---
  static const Color _lightBackground = Color(0xFFF7F7F7);
  static const Color _lightCardBackground = Color(0xFFEEEEEE);
  static const Color _lightPrimary = Color(0xFF929AAB);
  static const Color _lightTextDark = Color(0xFF393E46);
  static final Color _lightDivider = const Color(0xFF929AAB).withAlpha(80);

  // --- Dark Mode Colors (Companion Cool Gray Palette) ---
  static const Color _darkBackground = Color(0xFF393E46);
  static const Color _darkCardBackground = Color(0xFF4A505A); 
  // A darker, more subtle version for dark mode
  static const Color _darkPrimary = Color(0xFF7D8594); 
  static const Color _darkTextLight = Color(0xFFEEEEEE);
  static final Color _darkDivider = const Color(0xFF7D8594).withAlpha(80); // Using the new primary

  // --- Constant Colors (Same in Both Themes) ---
  static const Color _starYellow = Color(0xFFFFCF50);

  // --- General App Colors ---

  // Primary colors
  static Color get primary => _isDarkMode ? _darkPrimary : _lightPrimary;
  static Color get primaryLight => _isDarkMode ? _darkPrimary.withAlpha(220) : _lightPrimary.withAlpha(200);
  static Color get background => _isDarkMode ? _darkBackground : _lightBackground;
  static Color get accent => _isDarkMode ? _darkPrimary : _lightPrimary;

  // Success and Error (can remain the same or be themed)
  static Color get success => Colors.green.shade400;
  static Color get error => Colors.red.shade400;

  // Text colors
  static Color get textDark => _isDarkMode ? _darkTextLight : _lightTextDark;
  // UPDATED: Text on dark buttons should be light for readability
  static Color get textLight => _isDarkMode ? const Color(0xFFEEEEEE) : Colors.white;
  static Color get textMuted => _isDarkMode ? _darkTextLight.withAlpha(180) : _lightTextDark.withAlpha(150);

  // UI Element colors
  static Color get cardBackground => _isDarkMode ? _darkCardBackground : _lightCardBackground;
  static Color get divider => _isDarkMode ? _darkDivider : _lightDivider;
  static Color get shadow => _isDarkMode ?
                             Colors.black.withAlpha(102) : // Opacity 40%
                             _lightTextDark.withAlpha(30);   // Opacity ~12%
                             
  // Favorite/Star color - constant regardless of theme
  static Color get starYellow => _starYellow;
}