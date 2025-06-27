// The view for creating QR codes

import 'package:flutter/material.dart';
import 'qr_input_screen.dart';

class CreatorScreen extends StatelessWidget {
  static const List<String> qrTypes = ['URL', 'テキスト', '電話番号', 'Wi-Fi'];
  
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QRコードを作成")),
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
