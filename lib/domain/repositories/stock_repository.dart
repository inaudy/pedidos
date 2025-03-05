import 'package:pedidos/domain/entities/stock_item.dart';

abstract class StockRepository {
  Future<List<StockItem>> getAllStockItems();
  Future<void> addStockItem(StockItem item);
  Future<void> updateStockItem(StockItem item);
  Future<void> bulkInsert(List<StockItem> items);
}
