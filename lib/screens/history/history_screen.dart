import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/qr_code_model.dart';
import '../../providers/history_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/history/history_app_bar.dart';
import '../../widgets/history/selection_action_bar.dart';
import 'history_controller.dart';
import 'history_list_view.dart';

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
  
  // Controller
  late HistoryController _controller;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = HistoryController(
      context: context, 
      historyProvider: Provider.of<HistoryProvider>(context, listen: false),
    );
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
    
    final int count = _selectedItems.length;
    final List<int> ids = List.from(_selectedItems);
    
    // Show confirmation dialog
    final shouldDelete = await _controller.showDeleteConfirmationDialog(count);
    
    if (!shouldDelete) return;
    
    // Perform deletion
    await _controller.deleteMultipleQRCodes(ids);
    
    if (!mounted) return;
    
    // Show feedback
    _controller.showSnackbar('$count items deleted');
    
    _exitSelectionMode();
  }
  
  Future<void> _toggleFavoriteSelected(bool makeFavorite) async {
    if (_selectedItems.isEmpty) return;
    
    final int count = _selectedItems.length;
    final List<int> ids = List.from(_selectedItems);
    
    // Toggle favorites
    await _controller.toggleFavoriteMultiple(ids, makeFavorite);
    
    if (!mounted) return;
    
    // Show feedback
    _controller.showSnackbar(
      makeFavorite 
          ? '$count items added to favorites' 
          : '$count items removed from favorites'
    );
    
    _exitSelectionMode();
  }
  
  Future<bool> _handleFavoriteToggle(QRCodeModel item) async {
    if (item.id == null) return false;
    
    final bool currentlyFavorite = item.isFavorite;
    final int itemId = item.id!;
    final String message = currentlyFavorite
        ? 'Removed from favorites'
        : 'Added to favorites';
    
    // Show feedback
    _controller.showSnackbar(message, duration: const Duration(seconds: 1));
    
    // Toggle favorite
    await _controller.toggleFavorite(itemId);
    
    // Return false to prevent dismissal
    return false;
  }
  
  void _handleItemDelete(int itemId) {
    // Show feedback
    _controller.showSnackbar('Item deleted');
    
    // Delete item
    _controller.deleteQRCode(itemId);
  }
  
  void _toggleItemFavorite(QRCodeModel item) {
    if (item.id == null) return;
    
    final bool currentlyFavorite = item.isFavorite;
    final String message = currentlyFavorite
        ? 'Removed from favorites'
        : 'Added to favorites';
    
    // Show feedback
    _controller.showSnackbar(message, duration: const Duration(seconds: 1));
    
    // Toggle favorite
    _controller.toggleFavorite(item.id!);
  }
  
  @override
  Widget build(BuildContext context) {
    // Access theme provider
    Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _inSelectionMode 
          ? SelectionActionBar(
              selectedCount: _selectedItems.length,
              isFavoritesTab: _showFavoritesOnly,
              onClose: _exitSelectionMode,
              onSelectAll: () {
                final filteredHistory = _controller.getFilteredHistory(_showFavoritesOnly);
                _selectAll(filteredHistory);
              },
              onDelete: _deleteSelected,
              onToggleFavorite: () => _toggleFavoriteSelected(!_showFavoritesOnly),
            )
          : HistoryAppBar(tabController: _tabController),
      body: HistoryListView(
        showFavoritesOnly: _showFavoritesOnly,
        inSelectionMode: _inSelectionMode,
        selectedItems: _selectedItems,
        onToggleSelection: _toggleSelection,
        onEnterSelectionMode: _enterSelectionMode,
        onItemDelete: _handleItemDelete,
        onHandleFavoriteToggle: _handleFavoriteToggle,
        onToggleItemFavorite: _toggleItemFavorite,
      ),
    );
  }
} 