import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final String currentScreen;
  final Function? onScanTap;
  final Function? onCreatorTap;
  final Function? onHistoryTap;

  const BottomNavBar({
    Key? key,
    required this.currentScreen,
    this.onScanTap,
    this.onCreatorTap,
    this.onHistoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40), // Safe area for iPhone home indicator
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Scan button
          _buildNavButton(
            icon: Icons.crop_free,
            label: 'Scan',
            isActive: currentScreen == 'scan',
            onTap: () {
              if (currentScreen != 'scan' && onScanTap != null) {
                onScanTap!();
              }
            },
          ),
          
          // Creator button
          _buildNavButton(
            icon: Icons.qr_code_2,
            label: 'Creator',
            isActive: currentScreen == 'creator',
            onTap: () {
              if (currentScreen != 'creator' && onCreatorTap != null) {
                onCreatorTap!();
              }
            },
          ),
          
          // History button
          _buildNavButton(
            icon: Icons.history,
            label: 'History',
            isActive: currentScreen == 'history',
            onTap: () {
              if (currentScreen != 'history' && onHistoryTap != null) {
                onHistoryTap!();
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavButton({
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
} 