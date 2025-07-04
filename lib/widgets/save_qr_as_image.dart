import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_create_data.dart';
import '../models/qr_decoration_settings.dart';

/// 日付時刻をシンプルに「YYYYMMDD_HHMMSS」形式で返すヘルパー
String _getSimpleDateTimeString() {
  final now = DateTime.now();
  return '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '_'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
}

/// ImageProviderをui.Imageに変換するヘルパー
Future<ui.Image?> _imageProviderToUiImage(ImageProvider provider, int width, int height) async {
  final completer = Completer<ui.Image>();
  final imageStream = provider.resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(info.image);
  }, onError: (error, _) {
    completer.completeError(error);
  });
  imageStream.addListener(listener);
  try {
    return await completer.future;
  } finally {
    imageStream.removeListener(listener);
  }
}

/// QRコードを描画しPNGとしてファイルに保存する関数
/// ファイル名はfileNameが空なら日時付き自動生成
Future<String> saveQrAsImage({
  required QrCreateData qrData,
  required QrDecorationSettings settings,
  double baseQrSize = 400,
  String? fileName,
}) async {
  const double verticalMargin = 32.0;
  const double horizontalPadding = 32.0;

  final double qrSize = baseQrSize;
  final double iconSize = qrSize * 0.272;

  // ラベルサイズ計測（高さ・幅）
  double topTextHeight = 0, topTextWidth = 0;
  if (settings.topText != null && settings.topText!.isNotEmpty) {
    final topPainter = TextPainter(
      text: TextSpan(text: settings.topText!, style: settings.topLabelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    topTextHeight = topPainter.height + verticalMargin;
    topTextWidth = topPainter.width;
  }
  double bottomTextHeight = 0, bottomTextWidth = 0;
  if (settings.bottomText != null && settings.bottomText!.isNotEmpty) {
    final bottomPainter = TextPainter(
      text: TextSpan(text: settings.bottomText!, style: settings.bottomLabelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    bottomTextHeight = bottomPainter.height + verticalMargin;
    bottomTextWidth = bottomPainter.width;
  }

  // 横幅はQRサイズかラベル幅の最大値 + 横余白
  final double contentWidth = [qrSize, topTextWidth, bottomTextWidth].reduce((a, b) => a > b ? a : b);
  final double imageWidth = contentWidth + horizontalPadding * 2;

  // 縦幅は上下ラベル + QR + マージン
  final double imageHeight = topTextHeight + qrSize + bottomTextHeight + verticalMargin * 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();

  // 背景描画
  if (settings.backgroundStyle == 'transparent') {
    // 何もしない（透過）
  } else if (settings.backgroundStyle == 'rounded') {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      const Radius.circular(16),
    );
    paint.color = settings.backgroundColor;
    canvas.drawRRect(rrect, paint);
  } else if (settings.backgroundStyle == 'gradient') {
    paint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(imageWidth, imageHeight),
      [settings.backgroundColor, Colors.white],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, imageWidth, imageHeight), paint);
  } else {
    paint.color = settings.backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, imageWidth, imageHeight), paint);
  }

  // QRコード描画
  final qrPainter = QrPainter(
    data: qrData.content,
    version: QrVersions.auto,
    eyeStyle: QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: settings.foregroundColor,
    ),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: settings.foregroundColor,
    ),
    gapless: true,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
  );
  final qrOffset = Offset((imageWidth - qrSize) / 2, verticalMargin + topTextHeight);
  canvas.save();
  canvas.translate(qrOffset.dx, qrOffset.dy);
  qrPainter.paint(canvas, Size(qrSize, qrSize));
  canvas.restore();

  // 埋め込みアイコン描画（中央）
  if (settings.embeddedIcon != null) {
    final image = await _imageProviderToUiImage(
      settings.embeddedIcon!,
      (iconSize * 2).toInt(), // 高解像度で読み込み
      (iconSize * 2).toInt(),
    );
    if (image != null) {
      final iconOffset = Offset(
        (imageWidth - iconSize) / 2,
        verticalMargin + topTextHeight + (qrSize - iconSize) / 2,
      );
      paintImage(
        canvas: canvas,
        rect: iconOffset & Size(iconSize, iconSize),
        image: image,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }
  }

  // 上ラベル描画
  if (settings.topText != null && settings.topText!.isNotEmpty) {
    final textPainter = TextPainter(
      text: TextSpan(text: settings.topText!, style: settings.topLabelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: imageWidth);
    final offset = Offset((imageWidth - textPainter.width) / 2, verticalMargin / 2);
    textPainter.paint(canvas, offset);
  }

  // 下ラベル描画
  if (settings.bottomText != null && settings.bottomText!.isNotEmpty) {
    final textPainter = TextPainter(
      text: TextSpan(text: settings.bottomText!, style: settings.bottomLabelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: imageWidth);
    final offset = Offset((imageWidth - textPainter.width) / 2, verticalMargin + topTextHeight + qrSize + verticalMargin / 2);
    textPainter.paint(canvas, offset);
  }

  // 描画終了・画像化
  final picture = recorder.endRecording();
  final img = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) throw Exception("画像バイト変換に失敗しました");

  final buffer = byteData.buffer;
  final directory = await getApplicationDocumentsDirectory();

  // ファイル名が指定されなければ日時付き自動生成
  final safeFileName = fileName?.trim().isNotEmpty == true
      ? fileName!
      : 'qr_${_getSimpleDateTimeString()}.png';

  final filePath = '${directory.path}/$safeFileName';
  final file = File(filePath);
  await file.writeAsBytes(buffer.asUint8List());

  return filePath;
}
