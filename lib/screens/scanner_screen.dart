// Scanner screen implementation for QR and barcode scanning
// This is the primary entry point for the app

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../utils/app_colors.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

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
            icon: Icon(
              isFlashlightOn ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              setState(() {
                isFlashlightOn = !isFlashlightOn;
                controller.toggleTorch();
              });
            },
          ),
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
                      final String format = barcodes.first.format.name;
                      
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
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 250,
                  height: isQrMode ? 250 : 150, // Change height based on mode
                ),
              ],
            ),
          ),
          
          // Bottom controls for mode switching and flash
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Scanner mode button (left)
                _buildBottomButton(
                  icon: Icons.crop_free,
                  label: 'Scan',
                  isActive: true,
                ),
                
                // Switch between QR and barcode mode (middle)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isQrMode = !isQrMode;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        isQrMode 
                          ? Icons.qr_code 
                          : Icons.bar_chart_rounded,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
                
                // History button (right)
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