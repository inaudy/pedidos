import 'package:sqflite/sqflite.dart';
import '../../models/stock_transaction_model.dart';

class LocalStockTransactionDataSource {
  final Database db;

  LocalStockTransactionDataSource(this.db);

  /// ✅ Add transaction to SQLite
  Future<void> addTransaction(StockTransactionModel transaction) async {
    print(
        "Saving transaction locally: ${transaction.type} - ${transaction.change}");

    await db.insert(
      'stock_transactions',
      transaction.toSQLite()..['synced'] = 0, // ✅ Use SQLite format
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ Get transactions that have not been synced
  Future<List<StockTransactionModel>> getUnsyncedTransactions() async {
    final transactions = await db.query(
      'stock_transactions',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return transactions
        .map((txn) => StockTransactionModel.fromSQLite(txn))
        .toList(); // ✅ Use `fromSQLite()`
  }

  Future<List<StockTransactionModel>> getTransactionsForStock(
      String stockId, String posId) async {
    final transactions = await db.query(
      'stock_transactions',
      where: 'stockId = ? AND posId = ?',
      whereArgs: [stockId, posId],
      orderBy: 'timestamp DESC',
    );

    return transactions
        .map((txn) => StockTransactionModel.fromSQLite(txn))
        .toList();
  }

  /// ✅ **Clear transactions database (For reset)**
  Future<void> clearDatabase() async {
    await db.delete('stock_transactions');
    print("⚠️ Transactions cleared from local database.");
  }

  /// ✅ Mark transaction as synced
  Future<void> markTransactionAsSynced(String id) async {
    await db.update(
      'stock_transactions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
