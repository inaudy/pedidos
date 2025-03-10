import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_management.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1, // ✅ Keep version 1 since it's a new project
      onCreate: _createDB,
      onConfigure: _enableForeignKeys, // ✅ Ensure foreign keys are enabled
    );
  }

  Future<void> _enableForeignKeys(Database db) async {
    await db.execute(
        "PRAGMA foreign_keys = ON"); // ✅ Enforce foreign key constraints
  }

  Future<void> _createDB(Database db, int version) async {
    print("🔄 Creating SQLite tables...");

    // ✅ Create `stocks` table (Fix name)
    await db.execute('''
      CREATE TABLE stocks (
        stockId TEXT PRIMARY KEY,
        posId TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        bottleSize REAL NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL,
        packing TEXT NOT NULL,
        min REAL NOT NULL,
        max REAL NOT NULL,
        transfer TEXT,
        barcode TEXT,
        error REAL DEFAULT 0.0,
        updatedAt TEXT NOT NULL DEFAULT '',
        synced INTEGER DEFAULT 0 
      )
    ''');

    // ✅ Create `stock_transactions` table (Fix foreign key reference)
    await db.execute('''
      CREATE TABLE stock_transactions (
        id TEXT PRIMARY KEY,
        stockId TEXT NOT NULL,
        posId TEXT NOT NULL,
        user TEXT NOT NULL,
        change REAL NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        synced INTEGER DEFAULT 0, 
        FOREIGN KEY (stockId) REFERENCES stocks(stockId) ON DELETE CASCADE -- ✅ Fix: Use `stocks`
      )
    ''');
    print("✅ Tables Created Successfully");
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS stock_transactions");
    await db
        .execute("DROP TABLE IF EXISTS stocks"); // ✅ Fix: Correct table name
    await _createDB(db, 1);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
