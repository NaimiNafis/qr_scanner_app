import 'package:flutter/material.dart';
import '../../models/qr_create_data.dart';
import 'qr_result_screen.dart';

class QrInputScreen extends StatefulWidget {
  final String qrType;

  const QrInputScreen({Key? key, required this.qrType}) : super(key: key);

  @override
  State<QrInputScreen> createState() => _QrInputScreenState();
}

class _QrInputScreenState extends State<QrInputScreen> {
  final TextEditingController input1 = TextEditingController();
  final TextEditingController input2 = TextEditingController();
  final TextEditingController input3 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.qrType} の入力')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ..._buildInputsForType(widget.qrType),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onCreatePressed,
              child: const Text("QRコードを生成"),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInputsForType(String type) {
    switch (type) {
      case 'URL':
        return [
          TextField(
            controller: input1,
            decoration: const InputDecoration(labelText: 'URLを入力'),
          ),
        ];
      case 'Wi-Fi':
        return [
          TextField(
            controller: input1,
            decoration: const InputDecoration(labelText: 'SSID'),
          ),
          TextField(
            controller: input2,
            decoration: const InputDecoration(labelText: 'パスワード'),
          ),
        ];
      case '電話番号':
        return [
          TextField(
            controller: input1,
            decoration: const InputDecoration(labelText: '電話番号を入力'),
          ),
        ];
      default:
        return [
          TextField(
            controller: input1,
            decoration: const InputDecoration(labelText: '内容を入力'),
          ),
        ];
    }
  }

  void _onCreatePressed() {
    String qrData;

    switch (widget.qrType) {
      case 'Wi-Fi':
        qrData = 'WIFI:T:WPA;S:${input1.text};P:${input2.text};;';
        break;
      case '電話番号':
        qrData = 'tel:${input1.text}';
        break;
      default:
        qrData = input1.text;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrResultScreen(
          qrData: QrCreateData(type: widget.qrType, content: qrData),
        ),
      ),
    );
  }
}
