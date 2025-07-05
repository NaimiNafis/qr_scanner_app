import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/app_colors.dart';

class ScannerControls extends StatelessWidget {
  final bool isFlashlightOn;
  final bool isQrMode;
  final MobileScannerController controller;
  final Function(bool) onFlashToggle;
  final Function(bool) onModeToggle;
  
  const ScannerControls({
    super.key,
    required this.isFlashlightOn,
    required this.isQrMode,
    required this.controller,
    required this.onFlashToggle,
    required this.onModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Flash toggle
        GestureDetector(
          onTap: () {
            onFlashToggle(!isFlashlightOn);
            controller.toggleTorch();
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
          onTap: () => onModeToggle(!isQrMode),
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
    );
  }
} 