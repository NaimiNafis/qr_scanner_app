// Result screen implementation for displaying QR scan results
// Provides options to interact with the scanned content

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/history_provider.dart';
import '../utils/app_colors.dart';

class ResultScreen extends StatefulWidget {
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
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Track favorite status locally to update UI
  bool? _isFavorite;
  int? _currentId;
  
  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _currentId = widget.id;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          widget.type,
          style: TextStyle(color: AppColors.textLight),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentId != null && _isFavorite == true ? Icons.star : Icons.star_border,
              color: _currentId != null && _isFavorite == true ? AppColors.starYellow : AppColors.textLight,
            ),
            onPressed: () {
              final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
              
              if (_currentId != null) {
                // Update local state immediately for better UX
                setState(() {
                  _isFavorite = !(_isFavorite ?? false);
                });
                
                // Show feedback immediately
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFavorite == true 
                        ? 'Added to favorites' 
                        : 'Removed from favorites'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                
                // Toggle favorite for existing item
                historyProvider.toggleFavorite(_currentId!);
              } else {
                // This is a new scan, save it and mark as favorite
                _saveAndFavorite(historyProvider);
              }
            },
            tooltip: _currentId != null && _isFavorite == true ? 'Remove from favorites' : 'Add to favorites',
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
              widget.type,
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
                      _getIconForType(widget.type),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.type,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.content,
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
            if (widget.type == 'URL')
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
                  if (widget.type == 'URL' || widget.type == 'Youtube')
                    _buildActionButton(
                      context: context,
                      icon: Icons.chevron_right,
                      text: 'OPEN',
                      onTap: () => _launchURL(widget.content),
                    ),
                  
                  const SizedBox(height: 15),
                  
                  // COPY button
                  _buildActionButton(
                    context: context,
                    icon: Icons.copy,
                    text: 'COPY',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.content));
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
                        ShareParams(text: widget.content),
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

  void _saveAndFavorite(HistoryProvider historyProvider) {
    // Show feedback immediately
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving and adding to favorites...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Start saving process
    historyProvider.addQRCode(widget.content, widget.type).then((_) {
      // Find the newly added QR code to mark it as favorite
      historyProvider.fetchHistory().then((_) {
        // Get the latest added item (should be at the beginning of the list)
        final latestItems = historyProvider.history
            .where((item) => item.content == widget.content && item.type == widget.type)
            .toList();
        
        if (latestItems.isNotEmpty && mounted) {
          // Sort by timestamp to get the most recent one
          latestItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final latestItem = latestItems.first;
          
          // Update UI immediately
          setState(() {
            _currentId = latestItem.id;
            _isFavorite = true;
          });
          
          // Toggle favorite in database
          if (latestItem.id != null) {
            historyProvider.toggleFavorite(latestItem.id!);
          }
        }
      });
    });
  }
} 