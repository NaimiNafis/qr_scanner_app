import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const HistoryAppBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        'History',
        style: TextStyle(fontSize: 24, color: AppColors.textLight),
      ),
      automaticallyImplyLeading: false,
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Favorites'),
        ],
        labelColor: AppColors.textLight,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.textLight,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
} 