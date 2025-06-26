import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';

class QrDecorateScreen extends StatefulWidget {
  final QrCreateData qrData;

  const QrDecorateScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  State<QrDecorateScreen> createState() => _QrDecorateScreenState();
}

class _QrDecorateScreenState extends State<QrDecorateScreen> {
  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("QRコードをデコ"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 「生成」処理（後でQR保存など）
                Navigator.pop(context);
              },
              child: const Text("生成", style: TextStyle(color: Colors.white)),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "コード"),
              Tab(text: "背景"),
              Tab(text: "中央"),
              Tab(text: "文字"),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: QrImageView(
                data: widget.qrData.content,
                version: QrVersions.auto,
                size: 240,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCodeTab(),
                  _buildBackgroundTab(),
                  _buildCenterTab(),
                  _buildTextTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("前景色"),
          ElevatedButton(
            onPressed: () async {
              final newColor = await pickColor(foregroundColor);
              if (newColor != null) {
                setState(() => foregroundColor = newColor);
              }
            },
            child: const Text("色を選択"),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("背景色"),
          ElevatedButton(
            onPressed: () async {
              final newColor = await pickColor(backgroundColor);
              if (newColor != null) {
                setState(() => backgroundColor = newColor);
              }
            },
            child: const Text("色を選択"),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterTab() {
    return const Center(child: Text("中央の画像・文字（未実装）"));
  }

  Widget _buildTextTab() {
    return const Center(child: Text("上下の文字（未実装）"));
  }

  /// 色を選ぶ共通処理（ColorPicker入れるなら実装）
  Future<Color?> pickColor(Color current) async {
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("色を選択（仮）"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () => Navigator.pop(context, Colors.red), child: const Text("赤")),
            ElevatedButton(onPressed: () => Navigator.pop(context, Colors.green), child: const Text("緑")),
            ElevatedButton(onPressed: () => Navigator.pop(context, Colors.blue), child: const Text("青")),
          ],
        ),
      ),
    );
  }
}