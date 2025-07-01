// The view for showing history/favorites

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/qr_code_model.dart';
import '../utils/app_colors.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFavoritesOnly = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  void _handleTabChange() {
    setState(() {
      _showFavoritesOnly = _tabController.index == 1;
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'History',
          style: TextStyle(fontSize: 24, color: AppColors.textLight),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Favorites'),
          ],
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.textLight,
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          // Filter history based on the selected tab
          final filteredHistory = historyProvider.history.where((code) {
            if (_showFavoritesOnly) {
              return code.isFavorite;
            }
            return true;
          }).toList();
          
          if (filteredHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showFavoritesOnly ? Icons.star_border : Icons.history,
                    size: 80,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showFavoritesOnly
                        ? 'No favorites yet'
                        : 'No scan history yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showFavoritesOnly
                        ? 'Save important scans as favorites'
                        : 'Scan a QR code to see it here',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: filteredHistory.length,
            itemBuilder: (context, index) {
              final item = filteredHistory[index];
              return _buildHistoryItem(context, item);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildHistoryItem(BuildContext context, QRCodeModel item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              content: item.content,
              type: item.type,
              id: item.id,
              isFavorite: item.isFavorite,
            ),
          ),
        );
      },
      child: Dismissible(
        key: Key(item.id.toString()),
        background: Container(
          color: AppColors.accent,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Icon(
            item.isFavorite ? Icons.star_border : Icons.star,
            color: Colors.white,
          ),
        ),
        secondaryBackground: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Handle favorite toggle
            if (item.id != null) {
              await Provider.of<HistoryProvider>(context, listen: false)
                  .toggleFavorite(item.id!);
              
              // Show confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    item.isFavorite
                        ? 'Removed from favorites'
                        : 'Added to favorites',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            // Return false so the item is not dismissed
            return false;
          } else {
            // For endToStart (delete), return true to proceed with dismissal
            return true;
          }
        },
        onDismissed: (direction) {
          // This will only be called for endToStart (delete) swipes
          if (item.id != null) {
            Provider.of<HistoryProvider>(context, listen: false)
                .deleteQRCode(item.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item deleted')),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: _getIconForType(item.type),
            ),
            title: Text(
              item.type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: item.isFavorite
                ? Icon(Icons.star, color: AppColors.accent)
                : null,
          ),
        ),
      ),
    );
  }
  
  Widget _getIconForType(String type) {
    IconData iconData;
    
    switch (type) {
      case 'URL':
        iconData = Icons.link;
        break;
      case 'Youtube':
        iconData = Icons.play_circle_fill;
        break;
      case 'WI-FI':
        iconData = Icons.wifi;
        break;
      case 'Contacts':
        iconData = Icons.person;
        break;
      case 'PRODUCT':
        iconData = Icons.shopping_cart;
        break;
      default:
        iconData = Icons.text_snippet;
    }
    
    return Icon(iconData);
  }
}