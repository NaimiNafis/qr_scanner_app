// Defines colors used throughout the app  
import 'package:flutter/material.dart';

class AppColors {
  static bool _isDarkMode = false;
  
  // Method to update the theme mode
  static void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
  }
  
  // Primary colors
  static Color get primary => _isDarkMode ? Colors.brown.shade900 : Colors.brown.shade800;
  static Color get primaryLight => _isDarkMode ? Colors.brown.shade800 : Colors.brown.shade600;
  static Color get background => _isDarkMode ? Colors.grey.shade900 : Colors.brown.shade50;
  static Color get success => Colors.green;
  static Color get error => Colors.red;
  static Color get accent => Colors.amber.shade700;
  
  // Text colors
  static Color get textDark => _isDarkMode ? Colors.grey.shade300 : Colors.brown.shade900;
  static Color get textLight => _isDarkMode ? Colors.white : Colors.brown.shade50;
  static Color get textMuted => _isDarkMode ? Colors.grey.shade500 : Colors.brown.shade300;
  
  // UI Element colors
  static Color get cardBackground => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  static Color get divider => _isDarkMode ? Colors.grey.shade700 : Colors.brown.shade200;
  static Color get shadow => _isDarkMode ? 
                             Colors.black.withValues(alpha: 255 * 0.3) : 
                             Colors.grey.withValues(alpha: 255 * 0.2);
}  