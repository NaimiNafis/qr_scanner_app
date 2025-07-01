// Scanner screen implementation for QR and barcode scanning
// This is the primary entry point for the app

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../utils/app_colors.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isFlashlightOn = false;
  bool isQrMode = true; // true for QR, false for barcode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Scanner', style: TextStyle(color: AppColors.textLight)),
        actions: [
          IconButton(
            color: AppColors.textLight,
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings (to be implemented)
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
                    if (barcodes.isNotEmpty) {
                      // Stop scanning temporarily to prevent multiple scans
                      controller.stop();
                      
                      final String code = barcodes.first.rawValue ?? '';
                      
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
                        controller.start();
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
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                    Navigator.pushNamed(context, '/creator');
                  },
                ),
                
                // History button
                _buildBottomButton(
                  icon: Icons.history,
                  label: 'History',
                  isActive: false,
                  onTap: () {
                    Navigator.pushNamed(context, '/history');
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
    controller.dispose();
    super.dispose();
  }
} 