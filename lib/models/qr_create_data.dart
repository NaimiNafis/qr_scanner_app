class QrCreateData {
  final String type;      // 例: 'URL', 'Text'
  final String content;   // 実際にQRに埋め込む文字列

  QrCreateData({required this.type, required this.content});
}