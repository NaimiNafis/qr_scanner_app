import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SelectionActionBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final bool isFavoritesTab;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const SelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.isFavoritesTab,
    required this.onClose,
    required this.onSelectAll,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.textLight),
        onPressed: onClose,
      ),
      title: Text(
        '$selectedCount selected',
        style: TextStyle(fontSize: 20, color: AppColors.textLight),
      ),
      actions: [
        // Select all action
        IconButton(
          icon: Icon(Icons.select_all, color: AppColors.textLight),
          onPressed: onSelectAll,
          tooltip: 'Select all',
        ),
        // Add/remove favorite
        if (isFavoritesTab)
          IconButton(
            icon: Icon(Icons.star_border, color: AppColors.starYellow),
            onPressed: onToggleFavorite,
            tooltip: 'Remove from favorites',
          )
        else
          IconButton(
            icon: Icon(Icons.star, color: AppColors.starYellow),
            onPressed: onToggleFavorite,
            tooltip: 'Add to favorites',
          ),
        // Delete action
        IconButton(
          icon: Icon(Icons.delete, color: AppColors.textLight),
          onPressed: onDelete,
          tooltip: 'Delete selected',
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 