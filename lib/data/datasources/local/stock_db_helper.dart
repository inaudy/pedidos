import 'package:pedidos/core/constants/db_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StockDataBase {
  //Map to store the instances per sales point
  static final Map<String, StockDataBase> _instances = {};

  Database? _database;
  final String salesPointId;

  StockDataBase._(this.salesPointId);

  //Fatory method a singleton instance per sales point of a given sales point
  factory StockDataBase.getInstance(String salesPointId) {
    if (!_instances.containsKey(salesPointId)) {
      _instances[salesPointId] = StockDataBase._(salesPointId);
    }
    return _instances[salesPointId]!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_$salesPointId.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
    );
  }

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStocks(
        $colName TEXT PRIMARY KEY,
        $colQuantity REAL NOT NULL,
        $colCategory TEXT NOT NULL,
        $colUnit TEXT NOT NULL,
        $colLot INTEGER NOT NULL,
        $colMin REAL NOT NULL,
        $colMax REAL NOT NULL,
        $colTransfer TEXT,
        $colBarcode TEXT,
        $colError REAL NOT NULL
      )
    ''');
  }

  //CRUD Methods

  Future<int> createStockItem(Map<String, dynamic> itemMap) async {
    final db = await database;
    return await db.insert(tableStocks, itemMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //Get all stock items
  Future<List<Map<String, dynamic>>> getAllStockItems() async {
    final db = await database;
    return await db.query(tableStocks);
  }

  //Update stock item
  Future<int> updateStockItem(Map<String, dynamic> itemMap, String name) async {
    final db = await database;
    return await db.update(
      tableStocks,
      itemMap,
      where: '$colName = ?',
      whereArgs: [name],
    );
  }

  //Bulk insert
  Future<void> bulkInsertStockItem(List<Map<String, dynamic>> itemsMap) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in itemsMap) {
        await txn.insert(
          tableStocks,
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}
