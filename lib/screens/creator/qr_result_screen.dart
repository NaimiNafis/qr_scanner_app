import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';
import 'qr_decorate_screen.dart'; 

class QrResultScreen extends StatelessWidget {
  final QrCreateData qrData;

  QrResultScreen({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QRコードの結果")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData.content,
              version: QrVersions.auto,
              size: 240,
            ),
            SizedBox(height: 20),
            Text("種類: ${qrData.type}"),
            Text("内容: ${qrData.content}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrDecorateScreen(qrData: qrData),
                  ),
                );
              },
              child: const Text("デコレーションする"),
            ),
          ],
        ),
      ),
    );
  }
}