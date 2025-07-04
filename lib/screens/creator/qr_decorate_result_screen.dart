import 'package:flutter/material.dart';
import '../../models/qr_create_data.dart';
import '../../models/qr_decoration_settings.dart';
import '../../widgets/qr_preview_widget.dart';
//import '../../widgets/save_qr_as_image.dart';
import '../../utils/qr_capture_util.dart';

class QrDecorateResultScreen extends StatelessWidget {
  final QrCreateData qrData;
  final QrDecorationSettings decorationSettings;

  QrDecorateResultScreen({
    super.key,
    required this.qrData,
    required this.decorationSettings,
  });

  final GlobalKey _previewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QRコードプレビュー")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _previewKey,
              child: QrPreviewWidget(
                qrData: qrData,
                settings: decorationSettings,
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text("画像として保存"),
              onPressed: () async {
                try {
                  final path = await captureAndSave(_previewKey);
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("保存しました: $path")));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("保存に失敗しました: $e")));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
