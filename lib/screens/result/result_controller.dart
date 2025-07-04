import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/history_provider.dart';
import '../../models/qr_code_model.dart';

class ResultController {
  final BuildContext context;
  final HistoryProvider historyProvider;
  
  ResultController({
    required this.context,
    required this.historyProvider,
  });
  
  // Launch URL
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this URL'),
        ),
      );
    }
  }
  
  // Copy to clipboard
  void copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard')),
    );
  }
  
  // Share content
  void shareContent(String content) {
    SharePlus.instance.share(
      ShareParams(text: content),
    );
  }
  
  // Toggle favorite status
  Future<void> toggleFavorite(int id) async {
    await historyProvider.toggleFavorite(id);
  }
  
  // Save, mark as favorite, and return the new item
  Future<QRCodeModel> saveAndGetNewItem(String content, String type) async {
    // First check if this exact content already exists in history
    await historyProvider.fetchHistory();
    QRCodeModel? existingItem;
    
    try {
      existingItem = historyProvider.history.firstWhere(
        (item) => item.content == content && item.type == type,
      );
      
      // If the item already exists, use it
      if (existingItem.id != null) {
        // Only toggle if it's not already a favorite
        if (!existingItem.isFavorite) {
          await historyProvider.toggleFavorite(existingItem.id!);
          
          // Refresh to get updated item
          await historyProvider.fetchHistory();
          return historyProvider.history.firstWhere(
            (item) => item.id == existingItem!.id,
          );
        }
        return existingItem;
      }
    } catch (e) {
      // Item doesn't exist, continue to create it
    }
    
    // Otherwise add a new one
    await historyProvider.addQRCode(content, type);
    
    // Find the newly added code
    await historyProvider.fetchHistory();
    final newItem = historyProvider.history.firstWhere(
      (item) => item.content == content && item.type == type,
      orElse: () => throw Exception('Could not find newly added QR code'),
    );
    
    // Mark as favorite
    if (newItem.id != null) {
      await historyProvider.toggleFavorite(newItem.id!);
      
      // Refresh to get updated item
      await historyProvider.fetchHistory();
      return historyProvider.history.firstWhere(
        (item) => item.id == newItem.id,
      );
    }
    
    return newItem;
  }
  
  // Get icon for content type
  IconData getIconForType(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'WI-FI':
        return Icons.wifi;
      case 'CONTACTS':
        return Icons.person;
      case 'PRODUCT':
        return Icons.shopping_cart;
      default:
        return Icons.text_snippet;
    }
  }
  
  // Save and mark as favorite (for backward compatibility)
  Future<void> saveAndFavorite(String content, String type) async {
    await saveAndGetNewItem(content, type);
  }
} 