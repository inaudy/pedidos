import 'package:sqflite/sqflite.dart';
import '../../models/pos_model.dart';

class LocalPosDataSource {
  final Database db;

  LocalPosDataSource(this.db);

  /// ✅ Save POS to SQLite
  Future<void> savePos(PosModel pos) async {
    await db.insert(
      'pos',
      pos.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("📥 Saved POS to SQLite: ${pos.name}");
  }

  /// ✅ Fetch all POS from SQLite
  Future<List<PosModel>> getAllPos() async {
    final List<Map<String, dynamic>> maps = await db.query('pos');
    return maps.map((map) => PosModel.fromSQLite(map)).toList();
  }

  /// ✅ Get Unsynced POS from SQLite
  Future<List<PosModel>> getUnsyncedPos() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'pos',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => PosModel.fromSQLite(map)).toList();
  }

  /// ✅ Mark POS as synced in SQLite
  Future<void> markPosAsSynced(String id) async {
    await db.update(
      'pos',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    print("✅ POS [$id] marked as synced in SQLite.");
  }

  /// ✅ Check if POS data exists
  Future<bool> hasData() async {
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM pos'));
    return count != null && count > 0;
  }

  Future<void> deletePos(String id) async {
    await db.delete('pos', where: 'id = ?', whereArgs: [id]);
  }
}
