// The view for creating QR codes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import 'qr_input_screen.dart';

class CreatorScreen extends StatelessWidget {
  static const List<String> qrTypes = ['URL', 'テキスト', '電話番号', 'Wi-Fi'];
  
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme provider to ensure UI updates properly
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Create', style: TextStyle(color: AppColors.textLight)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: qrTypes.map((type) {
          return ListTile(
            title: Text(type),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrInputScreen(qrType: type),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
