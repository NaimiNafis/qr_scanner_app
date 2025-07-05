import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_app/providers/history_provider.dart';
import 'package:qr_scanner_app/providers/theme_provider.dart';
import 'package:qr_scanner_app/screens/scanner/scanner_screen.dart';
import 'package:qr_scanner_app/screens/history/history_screen.dart';
import 'package:qr_scanner_app/screens/creator/creator_screen.dart';
import 'package:qr_scanner_app/utils/app_colors.dart';
import 'package:qr_scanner_app/utils/theme_helper.dart';
import 'package:qr_scanner_app/widgets/bottom_nav_bar.dart';

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
      theme: ThemeHelper.getLightTheme(),
      darkTheme: ThemeHelper.getDarkTheme(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigationScreen(),
      routes: {
        '/result': (context) => const ScannerScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Screen names for the bottom nav bar
  final List<String> _screenNames = ['scan', 'creator', 'history'];
  
  void _changeScreen(int index) {
    if (_currentIndex == index) return; // Don't rebuild if already on this screen
    
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Listen to theme changes to ensure all screens update
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Update AppColors with current theme mode to ensure consistency
    AppColors.setDarkMode(themeProvider.isDarkMode);
    
    // Determine which screen to show
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = const ScannerScreen(key: ValueKey('scanner'));
        break;
      case 1:
        currentScreen = const CreatorScreen(key: ValueKey('creator'));
        break;
      case 2:
        currentScreen = const HistoryScreen(key: ValueKey('history'));
        break;
      default:
        currentScreen = const ScannerScreen(key: ValueKey('scanner'));
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Use fade transition instead of default slide transition
          return FadeTransition(opacity: animation, child: child);
        },
        child: currentScreen,
      ),
      bottomNavigationBar: BottomNavBar(
        currentScreen: _screenNames[_currentIndex],
        onScanTap: () => _changeScreen(0),
        onCreatorTap: () => _changeScreen(1),
        onHistoryTap: () => _changeScreen(2),
      ),
    );
  }
}
