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
  
  // Selection mode state
  bool _inSelectionMode = false;
  final Set<int> _selectedItems = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  void _handleTabChange() {
    setState(() {
      _showFavoritesOnly = _tabController.index == 1;
      // Exit selection mode when switching tabs
      _inSelectionMode = false;
      _selectedItems.clear();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _toggleSelection(int? id) {
    if (id == null) return;
    
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        if (_selectedItems.isEmpty) {
          _inSelectionMode = false;
        }
      } else {
        _selectedItems.add(id);
      }
    });
  }
  
  void _enterSelectionMode(int? id) {
    if (id == null) return;
    
    setState(() {
      _inSelectionMode = true;
      _selectedItems.add(id);
    });
  }
  
  void _exitSelectionMode() {
    setState(() {
      _inSelectionMode = false;
      _selectedItems.clear();
    });
  }
  
  void _selectAll(List<QRCodeModel> items) {
    setState(() {
      if (items.every((item) => _selectedItems.contains(item.id))) {
        // If all items are already selected, clear selection
        _selectedItems.clear();
        _inSelectionMode = false;
      } else {
        // Otherwise, select all items
        _selectedItems.addAll(items.map((item) => item.id!));
        _inSelectionMode = _selectedItems.isNotEmpty;
      }
    });
  }
  
  Future<void> _deleteSelected() async {
    if (_selectedItems.isEmpty) return;
    
    // Get selected items count and IDs before dialog
    final int count = _selectedItems.length;
    final List<int> ids = List.from(_selectedItems);
    
    // Store provider reference before any async operation
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    // Show dialog before any async operation
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $count items?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!shouldDelete) return;
    
    // Do the delete operation with previously stored provider
    await provider.deleteMultipleQRCodes(ids);
    
    // Check if still mounted before UI operations
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count items deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    _exitSelectionMode();
  }
  
  Future<void> _toggleFavoriteSelected(bool makeFavorite) async {
    if (_selectedItems.isEmpty) return;
    
    // Get selected items count and IDs before async operation
    final int count = _selectedItems.length;
    final List<int> ids = List.from(_selectedItems);
    
    // Do the toggle operation
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    await provider.toggleFavoriteMultiple(ids, makeFavorite);
    
    // Check if still mounted before UI operations
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          makeFavorite 
              ? '$count items added to favorites' 
              : '$count items removed from favorites'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    _exitSelectionMode();
  }
  
  // Handle favorite toggle with proper context safety
  Future<bool> _handleFavoriteToggle(QRCodeModel item) async {
    if (item.id == null) return false;
    
    // Get current favorite state and ID before async operation
    final bool currentlyFavorite = item.isFavorite;
    final int itemId = item.id!;
    final String message = currentlyFavorite
        ? 'Removed from favorites'
        : 'Added to favorites';
    
    // Show confirmation message immediately for better responsiveness
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
    
    // Get provider before async operation
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    // Toggle favorite state
    await provider.toggleFavorite(itemId);
    
    // Return false so the item is not dismissed
    return false;
  }
  
  // Handle item deletion with proper context safety
  void _handleItemDelete(int itemId) {
    // Show feedback immediately before any async operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted')),
    );
    
    // Delete operation after UI feedback has been shown
    Provider.of<HistoryProvider>(context, listen: false)
        .deleteQRCode(itemId);
  }
  
  // Handle toggling favorite status for a single item
  void _toggleItemFavorite(QRCodeModel item) {
    if (item.id == null) return;
    
    // Get current favorite state before toggling
    final bool currentlyFavorite = item.isFavorite;
    final String message = currentlyFavorite
        ? 'Removed from favorites'
        : 'Added to favorites';
        
    // Show feedback immediately for better responsiveness
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
    
    // Get provider and toggle favorite
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    provider.toggleFavorite(item.id!);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _inSelectionMode 
          ? _buildSelectionAppBar() 
          : _buildDefaultAppBar(),
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
              return _buildHistoryItem(context, item, filteredHistory);
            },
          );
        },
      ),
    );
  }
  
  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        'History',
        style: TextStyle(fontSize: 24, color: AppColors.textLight),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.textLight),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Lists'),
          Tab(text: 'Favorites'),
        ],
        labelColor: AppColors.textLight,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.textLight,
      ),
    );
  }
  
  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.textLight),
        onPressed: _exitSelectionMode,
      ),
      title: Text(
        '${_selectedItems.length} selected',
        style: TextStyle(fontSize: 20, color: AppColors.textLight),
      ),
      actions: [
        // Select all action
        IconButton(
          icon: Icon(Icons.select_all, color: AppColors.textLight),
          onPressed: () {
            final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
            final filteredHistory = historyProvider.history.where((code) {
              if (_showFavoritesOnly) {
                return code.isFavorite;
              }
              return true;
            }).toList();
            _selectAll(filteredHistory);
          },
        ),
        // Add/remove favorite
        if (_showFavoritesOnly)
          IconButton(
            icon: Icon(Icons.star_border, color: AppColors.textLight),
            onPressed: () => _toggleFavoriteSelected(false),
            tooltip: 'Remove from favorites',
          )
        else
          IconButton(
            icon: Icon(Icons.star, color: AppColors.textLight),
            onPressed: () => _toggleFavoriteSelected(true),
            tooltip: 'Add to favorites',
          ),
        // Delete action
        IconButton(
          icon: Icon(Icons.delete, color: AppColors.textLight),
          onPressed: _deleteSelected,
          tooltip: 'Delete selected',
        ),
      ],
    );
  }
  
  Widget _buildHistoryItem(BuildContext context, QRCodeModel item, List<QRCodeModel> allItems) {
    final bool isSelected = item.id != null && _selectedItems.contains(item.id);
    
    return InkWell(
      onTap: () {
        if (_inSelectionMode) {
          _toggleSelection(item.id);
        } else {
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
        }
      },
      onLongPress: () {
        if (!_inSelectionMode) {
          _enterSelectionMode(item.id);
        }
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
        direction: _inSelectionMode ? DismissDirection.none : DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Handle favorite toggle
            return await _handleFavoriteToggle(item);
          } else {
            // For endToStart (delete), return true to proceed with dismissal
            return true;
          }
        },
        onDismissed: (direction) {
          // This will only be called for endToStart (delete) swipes
          if (item.id != null) {
            _handleItemDelete(item.id!);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 40) : AppColors.cardBackground,
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
            leading: _inSelectionMode 
              ? Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : const SizedBox(width: 20, height: 20),
                )
              : Container(
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
            trailing: !_inSelectionMode
                ? IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      color: item.isFavorite ? AppColors.accent : AppColors.textMuted,
                    ),
                    onPressed: () {
                      if (item.id != null) {
                        _toggleItemFavorite(item);
                      }
                    },
                    tooltip: item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  )
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