// Defines the structure of a history item

class QRCodeModel {
  final int? id;
  final String content;
  final String type;
  final bool isFavorite;
  final DateTime timestamp;

  QRCodeModel({
    this.id,
    required this.content,
    required this.type,
    this.isFavorite = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'isFavorite': isFavorite ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QRCodeModel.fromMap(Map<String, dynamic> map) {
    return QRCodeModel(
      id: map['id'],
      content: map['content'],
      type: map['type'],
      isFavorite: map['isFavorite'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}