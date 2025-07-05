import 'package:flutter/material.dart';
import '../../models/qr_code_model.dart';
import '../../providers/history_provider.dart';

class HistoryController {
  final BuildContext context;
  final HistoryProvider historyProvider;
  
  HistoryController({
    required this.context,
    required this.historyProvider,
  });
  
  // Show confirmation dialog for deletion
  Future<bool> showDeleteConfirmationDialog(int count) async {
    return await showDialog<bool>(
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
  }
  
  // Delete multiple QR codes
  Future<void> deleteMultipleQRCodes(List<int> ids) async {
    await historyProvider.deleteMultipleQRCodes(ids);
  }
  
  // Delete a single QR code
  Future<void> deleteQRCode(int id) async {
    await historyProvider.deleteQRCode(id);
  }
  
  // Toggle favorite status for multiple QR codes
  Future<void> toggleFavoriteMultiple(List<int> ids, bool makeFavorite) async {
    await historyProvider.toggleFavoriteMultiple(ids, makeFavorite);
  }
  
  // Toggle favorite status for a single QR code
  Future<void> toggleFavorite(int id) async {
    await historyProvider.toggleFavorite(id);
  }
  
  // Get filtered history items based on favorites filter
  List<QRCodeModel> getFilteredHistory(bool showFavoritesOnly) {
    return historyProvider.history.where((code) {
      if (showFavoritesOnly) {
        return code.isFavorite;
      }
      return true;
    }).toList();
  }
  
  // Show a snackbar message
  void showSnackbar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
} 