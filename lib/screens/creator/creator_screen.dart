// The view for creating QR codes

import 'package:flutter/material.dart';
import 'qr_input_screen.dart';

class CreatorScreen extends StatelessWidget {
  final List<String> qrTypes = ['URL', 'テキスト', '電話番号', 'Wi-Fi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QRコードを作成")),
      body: ListView(
        children: qrTypes.map((type) {
          return ListTile(
            title: Text(type),
            trailing: Icon(Icons.chevron_right),
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
