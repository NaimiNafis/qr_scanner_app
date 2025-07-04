// Scanner screen implementation for QR and barcode scanning
// This is the primary entry point for the app

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController controller;
  bool isFlashlightOn = false;
  bool isQrMode = true; // true for QR, false for barcode
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    // Initialize controller with all formats
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
    
    // Register this object as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.paused) {
      controller.stop();
    }
  }

  // Filter barcodes based on selected mode
  bool _shouldProcessBarcode(Barcode barcode) {
    if (isQrMode) {
      return barcode.format == BarcodeFormat.qrCode;
    } else {
      return barcode.format != BarcodeFormat.qrCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Scanner', style: TextStyle(color: AppColors.textLight)),
        actions: [
          IconButton(
            color: AppColors.textLight,
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner view with frame
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scanner view
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    
                    // Filter barcodes based on selected mode
                    final matchingBarcodes = barcodes.where(_shouldProcessBarcode).toList();
                    
                    if (matchingBarcodes.isNotEmpty && isScanning) {
                      // Stop scanning temporarily to prevent multiple scans
                      setState(() {
                        isScanning = false;
                      });
                      
                      final String code = matchingBarcodes.first.rawValue ?? '';
                      
                      // Determine the type based on content heuristics
                      String type = _determineContentType(code);
                      
                      // Add to history
                      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
                      historyProvider.addQRCode(code, type);
                      
                      // Navigate to results screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            content: code,
                            type: type,
                          ),
                        ),
                      ).then((_) {
                        // Resume scanning when returning from result screen
                        setState(() {
                          isScanning = true;
                        });
                      });
                    }
                  },
                ),
                
                // Scan frame
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 5, // Bolder border
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 250,
                  height: isQrMode ? 250 : 150, // Change height based on mode
                ),
                
                // Scanner controls - positioned towards the bottom of the scanner view
                Positioned(
                  bottom: 70, // Positioned higher up from the bottom
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flash toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isFlashlightOn = !isFlashlightOn;
                            controller.toggleTorch();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Icon(
                            isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                            color: AppColors.textLight,
                            size: 28,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 60),
                      
                      // QR/Barcode toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isQrMode = !isQrMode;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Icon(
                            isQrMode ? Icons.qr_code : Icons.view_week,
                            color: AppColors.textLight,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom navigation bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40), // Added more padding to raise the bar and protect from accidental iPhone home bar touches
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Scan button (current screen)
                _buildBottomButton(
                  icon: Icons.crop_free,
                  label: 'Scan',
                  isActive: true,
                ),
                
                // Creator button (navigates to creator screen)
                _buildBottomButton(
                  icon: Icons.qr_code_2,
                  label: 'Creator',
                  isActive: false,
                  onTap: () {
                    // Stop scanning when navigating away
                    controller.stop();
                    Navigator.pushNamed(context, '/creator').then((_) {
                      // Resume scanning when returning to this screen
                      controller.start();
                    });
                  },
                ),
                
                // History button
                _buildBottomButton(
                  icon: Icons.history,
                  label: 'History',
                  isActive: false,
                  onTap: () {
                    // Stop scanning when navigating away
                    controller.stop();
                    Navigator.pushNamed(context, '/history').then((_) {
                      // Resume scanning when returning to this screen
                      controller.start();
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.textLight : AppColors.textMuted,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.textLight : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to determine content type
  String _determineContentType(String content) {
    content = content.toLowerCase();
    
    if (content.startsWith('http://') || content.startsWith('https://')) {
      if (content.contains('youtube.com') || content.contains('youtu.be')) {
        return 'Youtube';
      }
      return 'URL';
    } else if (content.contains('ssid') || content.contains('wifi')) {
      return 'WI-FI';
    } else if (content.contains('tel:') || content.contains('contact')) {
      return 'Contacts';
    } else if (content.length >= 8 && content.length <= 14 && num.tryParse(content.replaceAll(RegExp(r'[^0-9]'), '')) != null) {
      return 'PRODUCT';
    }
    
    return 'Text';
  }

  @override
  void dispose() {
    // Clean up observers and controller
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }
} 