import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPixelPainter extends StatelessWidget {
  final String data;
  final double size;
  final QrDataModuleShape pixelShape;
  final QrEyeShape eyeShape;
  final Color color;

  const QrPixelPainter({
    super.key,
    required this.data,
    this.size = 200,
    this.pixelShape = QrDataModuleShape.square,
    this.eyeShape = QrEyeShape.square,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      eyeStyle: QrEyeStyle(eyeShape: eyeShape, color: color),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: pixelShape,
        color: color,
      ),
    );
  }
}
