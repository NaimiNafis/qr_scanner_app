// Scanner screen implementation for QR and barcode scanning
// This is the primary entry point for the app

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late MobileScannerController controller;
  bool isFlashlightOn = false;
  bool isQrMode = true; // true for QR, false for barcode
  bool isScanning = true;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true; // Keep this screen alive

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with all formats
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
    
    // Register this object as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Allow the frame to be drawn before initializing camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isInitialized = true;
      });
    });
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Scan', style: TextStyle(color: AppColors.textLight)),
        automaticallyImplyLeading: false, // Prevent automatic back button
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
                // Scanner view or loading indicator
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isInitialized 
                    ? MobileScanner(
                        key: const ValueKey('scanner-active'),
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
                      )
                    : Container(
                        key: const ValueKey('scanner-loading'),
                        color: AppColors.background,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                ),
                
                // Scan frame is always visible, even during loading
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