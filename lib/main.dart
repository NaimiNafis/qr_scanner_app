import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_app/providers/history_provider.dart';
import 'package:qr_scanner_app/screens/scanner_screen.dart';
import 'package:qr_scanner_app/screens/history_screen.dart';
import 'package:qr_scanner_app/screens/creator_screen.dart';

// Main entry point for the app
// Sets up provider for state management and configures the app theme

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ScannerScreen(),
      routes: {
        '/history': (context) => const HistoryScreen(),
        '/creator': (context) => const CreatorScreen(),
      },
    );
  }
}
