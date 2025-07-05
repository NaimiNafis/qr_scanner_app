import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/qr_code_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qr_history.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE qr_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        isFavorite INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        isSafe INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE qr_codes ADD COLUMN isSafe INTEGER NOT NULL DEFAULT 1');
    }
  }

  Future<int> insertQRCode(QRCodeModel qrCode) async {
    final db = await database;
    return await db.insert('qr_codes', qrCode.toMap());
  }

  Future<List<QRCodeModel>> getQRCodes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('qr_codes', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return QRCodeModel.fromMap(maps[i]);
    });
  }

  Future<int> updateQRCode(QRCodeModel qrCode) async {
    final db = await database;
    return await db.update(
      'qr_codes',
      qrCode.toMap(),
      where: 'id = ?',
      whereArgs: [qrCode.id],
    );
  }

  Future<int> deleteQRCode(int id) async {
    final db = await database;
    return await db.delete(
      'qr_codes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMultipleQRCodes(List<int> ids) async {
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    return await db.delete(
      'qr_codes',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }
}