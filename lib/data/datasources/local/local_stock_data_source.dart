import 'package:sqflite/sqflite.dart';
import '../../models/stock_item_model.dart';

class LocalStockDataSource {
  final Database db;

  LocalStockDataSource(this.db);

  /// ✅ Save stock item & mark as unsynced if updated
  Future<void> saveStockItem(StockItemModel stock) async {
    final existingItem = await getStockById(stock.stockId, stock.posId);

    if (existingItem == null ||
        existingItem.updatedAt.isBefore(stock.updatedAt)) {
      await db.insert(
        'stocks',
        stock.toSQLite()..['synced'] = 0, // ✅ Always mark as unsynced on save
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("📥 Saved to SQLite & marked as unsynced: ${stock.name}");
    } else {
      print("⚠️ Skip saving. Local data is already up-to-date: ${stock.name}");
    }
  }

  /// ✅ Fetch a specific stock item by `stockId` and `posId`
  Future<StockItemModel?> getStockById(String stockId, String posId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'stocks',
      where: 'stockId = ? AND posId = ?',
      whereArgs: [stockId, posId],
    );

    if (maps.isNotEmpty) {
      return StockItemModel.fromSQLite(maps.first);
    } else {
      return null;
    }
  }

  /// ✅ Get all stock from SQLite
  Future<List<StockItemModel>> getAllStock(String posId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'stocks',
      where: 'posId = ?',
      whereArgs: [posId],
    );

    print("🔍 Retrieved ${maps.length} items from SQLite for POS: $posId");

    return maps.map((e) => StockItemModel.fromSQLite(e)).toList();
  }

  /// ✅ Get stock items that need to be synced
  Future<List<StockItemModel>> getUnsyncedStock(String posId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'stocks',
      where: 'posId = ? AND synced = 0',
      whereArgs: [posId],
    );

    return maps.map((e) => StockItemModel.fromSQLite(e)).toList();
  }

  Future<bool> hasData(String posId) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM stocks WHERE posId = ?', [posId]),
    );
    return count != null && count > 0;
  }

  Future<void> markStockAsUnsynced(String stockId) async {
    await db.update(
      'stocks',
      {'synced': 0}, // 0 = Unsynced
      where: 'stockId = ?',
      whereArgs: [stockId],
    );
    print("⚠️ Marked stock [$stockId] as UNSYNCED.");
  }

  /// ✅ **Clear stock database (For reset)**
  Future<void> clearDatabase() async {
    await db.delete('stocks');
    await db.delete('stock_transactions');
    print("⚠️ Local database cleared.");
  }

  /// ✅ Mark a stock item as synced
  Future<void> markStockAsSynced(String stockId) async {
    await db.update(
      'stocks',
      {'synced': 1},
      where: 'stockId = ?',
      whereArgs: [stockId],
    );
  }
}
