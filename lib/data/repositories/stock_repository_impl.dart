import 'package:pedidos/data/datasources/local/stock_db_helper.dart';
import 'package:pedidos/data/models/stock_item.dart';
import 'package:pedidos/domain/entities/stock_item.dart';
import 'package:pedidos/domain/repositories/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  final StockDataBase dbHelper;

  StockRepositoryImpl(this.dbHelper);

  @override
  Future<List<StockItem>> getAllStockItems() async {
    final List<Map<String, dynamic>> maps = await dbHelper.getAllStockItems();
    return maps.map((map) => StockItemModel.fromMap(map)).toList();
  }

  @override
  Future<void> addStockItem(StockItem item) async {
    final model = item is StockItemModel
        ? item
        : StockItemModel(
            name: item.name,
            quantity: item.quantity,
            category: item.category,
            unit: item.unit,
            lot: item.lot,
            min: item.min,
            max: item.max,
            transfer: item.transfer,
            barcode: item.barcode,
            error: item.error,
          );
    await dbHelper.createStockItem(model.toMap());
  }

  @override
  Future<void> updateStockItem(StockItem item) async {
    final model = item is StockItemModel
        ? item
        : StockItemModel(
            name: item.name,
            quantity: item.quantity,
            category: item.category,
            unit: item.unit,
            lot: item.lot,
            min: item.min,
            max: item.max,
            transfer: item.transfer,
            barcode: item.barcode,
            error: item.error,
          );
    await dbHelper.updateStockItem(model.toMap(), model.name);
  }

  @override
  Future<void> bulkInsert(List<StockItem> items) async {
    //Convert the list of StockItem to a list of Map
    final itemsMap = items.map((item) {
      final model = item is StockItemModel
          ? item
          : StockItemModel(
              name: item.name,
              quantity: item.quantity,
              category: item.category,
              unit: item.unit,
              lot: item.lot,
              min: item.min,
              max: item.max,
              transfer: item.transfer,
              barcode: item.barcode,
              error: item.error,
            );
      return model.toMap();
    }).toList();
    //Use the bulkInsert method from the database helper
    await dbHelper.bulkInsertStockItem(itemsMap);
  }
}
