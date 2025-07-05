import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widgets/scanner/scan_frame.dart';
import '../../widgets/scanner/scanner_controls.dart';
import '../../widgets/scanner/scanner_loading.dart';

class ScannerView extends StatelessWidget {
  final MobileScannerController controller;
  final bool isInitialized;
  final bool isFlashlightOn;
  final bool isQrMode;
  final bool isScanning;
  final Function(bool) onFlashToggle;
  final Function(bool) onModeToggle;
  final Function(BarcodeCapture) onDetect;
  
  const ScannerView({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.isFlashlightOn,
    required this.isQrMode,
    required this.isScanning,
    required this.onFlashToggle,
    required this.onModeToggle,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Scanner view or loading indicator
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isInitialized 
            ? MobileScanner(
                key: const ValueKey('scanner-active'),
                controller: controller,
                onDetect: onDetect,
              )
            : const ScannerLoading(key: ValueKey('scanner-loading')),
        ),
        
        // Scan frame is always visible, even during loading
        ScanFrame(isQrMode: isQrMode),
        
        // Scanner controls - positioned towards the bottom of the scanner view
        Positioned(
          bottom: 70, // Positioned higher up from the bottom
          child: ScannerControls(
            isFlashlightOn: isFlashlightOn,
            isQrMode: isQrMode,
            controller: controller,
            onFlashToggle: onFlashToggle,
            onModeToggle: onModeToggle,
          ),
        ),
      ],
    );
  }
} 