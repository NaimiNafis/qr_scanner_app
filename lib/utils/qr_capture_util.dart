import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

Future<String> captureAndSave(
  GlobalKey repaintKey, {
  String fileName = 'qr_capture.png',
}) async {
  try {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception("RepaintBoundaryが見つかりません");
    }

    final ui.Image image = await boundary.toImage(
      pixelRatio: ui.window.devicePixelRatio,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception("画像のByteData取得に失敗");
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';

    final file = File(path);
    await file.writeAsBytes(pngBytes);

    return path;
  } catch (e) {
    rethrow;
  }
}
