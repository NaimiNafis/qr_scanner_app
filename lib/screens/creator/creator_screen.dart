// The view for creating QR codes

import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'qr_input_screen.dart';

class CreatorScreen extends StatelessWidget {
  static const List<Map<String, dynamic>> qrTypes = [
    {
      'type': 'URL',
      'icon': Icons.link,
      'example': 'e.g., https://kit-isel.github.io/',
      'tooltip': 'Create QR codes that open websites or web apps when scanned'
    },
    {
      'type': 'Text',
      'icon': Icons.text_fields,
      'example': 'e.g., Meeting notes, contact info',
      'tooltip': 'Store plain text information in a QR code'
    },
    {
      'type': 'Phone Number',
      'icon': Icons.phone,
      'example': 'e.g., +81 90 1234 5678',
      'tooltip': 'Generate a QR code that opens the phone dialer when scanned'
    },
    {
      'type': 'Wi-Fi',
      'icon': Icons.wifi,
      'example': 'e.g., Network name (SSID) & password',
      'tooltip': 'Share Wi-Fi credentials via QR code for easy connection'
    },
  ];
  
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Creator', style: TextStyle(color: AppColors.textLight)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Select a QR code type to create',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Grid of options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: qrTypes.map((typeInfo) {
                  return _buildTypeCard(
                    context,
                    typeInfo['type'],
                    typeInfo['icon'],
                    typeInfo['example'],
                    typeInfo['tooltip'],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeCard(
    BuildContext context, 
    String type, 
    IconData icon, 
    String example,
    String tooltip,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrInputScreen(qrType: type),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.cardBackground,
        child: Stack(
          children: [
            // Main card content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tooltip button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  _showTooltip(context, type, tooltip);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTooltip(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        backgroundColor: AppColors.cardBackground,
        titleTextStyle: TextStyle(
          color: AppColors.primary, 
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
        ),
        actions: [
          TextButton(
            child: Text(
              'Got it',
              style: TextStyle(color: AppColors.primary),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
