import 'package:flutter/material.dart';
import '../api/db_helper.dart';
import '../models/qr_code_model.dart';

class HistoryProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<QRCodeModel> _history = [];
  List<QRCodeModel> get history => _history;

  HistoryProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    _history = await _dbHelper.getQRCodes();
    notifyListeners();
  }

  Future<void> addQRCode(String content, String type) async {
    final newCode = QRCodeModel(
      content: content,
      type: type,
      timestamp: DateTime.now(),
    );
    await _dbHelper.insertQRCode(newCode);
    await fetchHistory();
  }

  Future<void> toggleFavorite(int id) async {
    final code = _history.firstWhere((element) => element.id == id);
    final updatedCode = QRCodeModel(
      id: code.id,
      content: code.content,
      type: code.type,
      isFavorite: !code.isFavorite,
      timestamp: code.timestamp,
    );
    await _dbHelper.updateQRCode(updatedCode);
    await fetchHistory();
  }

  Future<void> deleteQRCode(int id) async {
    await _dbHelper.deleteQRCode(id);
    await fetchHistory();
  }
}

// Manages history/favorites state and logic