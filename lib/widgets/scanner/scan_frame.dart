import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ScanFrame extends StatelessWidget {
  final bool isQrMode;
  
  const ScanFrame({
    super.key,
    required this.isQrMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary,
          width: 5, // Bolder border
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      width: 250,
      height: isQrMode ? 250 : 150, // Change height based on mode
    );
  }
} 