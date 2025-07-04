import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_app/providers/history_provider.dart';
import 'package:qr_scanner_app/providers/theme_provider.dart';
import 'package:qr_scanner_app/screens/scanner_screen.dart';
import 'package:qr_scanner_app/screens/history_screen.dart';
import 'package:qr_scanner_app/screens/creator/creator_screen.dart';
import 'package:qr_scanner_app/utils/app_colors.dart';

// Main entry point for the app
// Sets up provider for state management and configures the app theme

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Update AppColors with current theme mode
    AppColors.setDarkMode(themeProvider.isDarkMode);
    
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: const ScannerScreen(),
      routes: {
        '/history': (context) => const HistoryScreen(),
        '/creator': (context) => const CreatorScreen(),
      },
    );
  }
}
