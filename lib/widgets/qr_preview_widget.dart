//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_create_data.dart';
import '../models/qr_decoration_settings.dart';

class QrPreviewWidget extends StatelessWidget {
  final QrCreateData qrData;
  final QrDecorationSettings settings;

  const QrPreviewWidget({
    super.key,
    required this.qrData,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // 背景の装飾スタイル決定
    BoxDecoration decoration;
    if (settings.backgroundStyle == 'transparent') {
      decoration = const BoxDecoration(color: Colors.transparent);
    } else if (settings.backgroundStyle == 'rounded') {
      decoration = BoxDecoration(
        color: settings.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      );
    } else if (settings.backgroundStyle == 'gradient') {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [settings.backgroundColor, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      decoration = BoxDecoration(color: settings.backgroundColor);
    }

    // 埋め込み画像の優先順位（embeddedIcon > embeddedImage）
    ImageProvider<Object>? getEmbeddedImage() {
      if (settings.embeddedIcon != null) {
        return settings.embeddedIcon;
      }
      if (settings.embeddedImage != null) {
        return FileImage(settings.embeddedImage!);
      }
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 上部テキスト
        if (settings.topText != null && settings.topText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(settings.topText!, style: settings.topLabelStyle),
          ),

        // QRコード本体
        Container(
          padding: const EdgeInsets.all(16),
          decoration: decoration,
          child: QrImageView(
            data: qrData.content,
            version: QrVersions.auto,
            size: 200,
            foregroundColor: settings.foregroundColor,
            backgroundColor: Colors.transparent,
            embeddedImage: getEmbeddedImage(),
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(48, 48),
            ),
            errorCorrectionLevel: QrErrorCorrectLevel.H,
          ),
        ),

        // 下部テキスト
        if (settings.bottomText != null && settings.bottomText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(settings.bottomText!, style: settings.bottomLabelStyle),
          ),
      ],
    );
  }
}
