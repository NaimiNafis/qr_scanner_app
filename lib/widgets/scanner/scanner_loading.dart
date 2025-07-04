import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ScannerLoading extends StatelessWidget {
  const ScannerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
} 