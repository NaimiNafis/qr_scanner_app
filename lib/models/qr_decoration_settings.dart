import 'dart:io';
import 'package:flutter/material.dart';

class QrDecorationSettings {
  final Color foregroundColor;
  final Color backgroundColor;
  final String pixelShape;
  final String backgroundStyle;
  final IconData? centerIcon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String? topText;
  final TextStyle topLabelStyle;
  final String? bottomText;
  final TextStyle bottomLabelStyle;
  final File? embeddedImage;

  QrDecorationSettings({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.pixelShape,
    required this.backgroundStyle,
    required this.centerIcon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.topText,
    required this.topLabelStyle,
    required this.bottomText,
    required this.bottomLabelStyle,
    required this.embeddedImage,
  });

  // 必要なら toJson() / fromJson() を追加
}
