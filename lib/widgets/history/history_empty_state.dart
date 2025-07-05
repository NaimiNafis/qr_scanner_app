import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class HistoryEmptyState extends StatelessWidget {
  final bool isFavoritesTab;
  
  const HistoryEmptyState({
    super.key,
    required this.isFavoritesTab,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFavoritesTab ? Icons.star_border : Icons.history,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            isFavoritesTab
                ? 'No favorites yet'
                : 'No scan history yet',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFavoritesTab
                ? 'Save important scans as favorites'
                : 'Scan a QR code to see it here',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
} 