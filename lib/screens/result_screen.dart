// Result screen implementation for displaying QR scan results
// Provides options to interact with the scanned content

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/history_provider.dart';
import '../utils/app_colors.dart';

class ResultScreen extends StatelessWidget {
  final String content;
  final String type;
  final int? id;
  final bool? isFavorite;

  const ResultScreen({
    super.key,
    required this.content,
    required this.type,
    this.id,
    this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          type,
          style: TextStyle(color: AppColors.textLight),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (id != null) {
                final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
                historyProvider.toggleFavorite(id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isFavorite == true 
                        ? 'Removed from favorites' 
                        : 'Added to favorites'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              } else {
                // This is a new scan, not yet in history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Save a scan before adding to favorites'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              id != null && isFavorite == true ? 'Remove favorite' : 'Save as Favorites',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content type heading
            Text(
              type,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 30),
            
            // Content display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          content,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Safety check for URLs
            if (type == 'URL')
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.success, width: 2),
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.success.withValues(alpha: 255 * 0.05),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This link is safe to open!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // OPEN button (for URLs)
                  if (type == 'URL' || type == 'Youtube')
                    _buildActionButton(
                      context: context,
                      icon: Icons.chevron_right,
                      text: 'OPEN',
                      onTap: () => _launchURL(content),
                    ),
                  
                  const SizedBox(height: 15),
                  
                  // COPY button
                  _buildActionButton(
                    context: context,
                    icon: Icons.copy,
                    text: 'COPY',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Content copied to clipboard')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // SHARE button
                  _buildActionButton(
                    context: context,
                    icon: Icons.share,
                    text: 'SHARE',
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(text: content),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'Youtube':
        return Icons.play_circle_fill;
      case 'WI-FI':
        return Icons.wifi;
      case 'Contacts':
        return Icons.person;
      case 'PRODUCT':
        return Icons.shopping_cart;
      default:
        return Icons.text_snippet;
    }
  }

  Future<void> _launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      debugPrint('Could not launch $url');
    }
  }
} 