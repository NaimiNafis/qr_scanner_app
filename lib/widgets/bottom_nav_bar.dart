import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final String currentScreen;
  final Function? onScanTap;
  final Function? onCreatorTap;
  final Function? onHistoryTap;

  const BottomNavBar({
    super.key,
    required this.currentScreen,
    this.onScanTap,
    this.onCreatorTap,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? AppColors.cardBackground : AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40), // Safe area for iPhone home indicator
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Scan button
          _buildNavButton(
            context: context,
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
            context: context,
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
            context: context,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive 
                ? (isDark ? AppColors.primary : AppColors.textLight) 
                : (isDark ? AppColors.textMuted : AppColors.textMuted),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive 
                  ? (isDark ? AppColors.primary : AppColors.textLight) 
                  : (isDark ? AppColors.textMuted : AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
} 