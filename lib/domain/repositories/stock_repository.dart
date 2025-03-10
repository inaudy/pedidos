import '../entities/stock_item.dart';
import '../entities/stock_transaction.dart';

abstract class StockRepository {
  Future<List<StockItem>> getAllStock(String posId);
  Future<StockItem> getStockById(
      String stockId, String posId); // ✅ Ensure this exists
  Future<void> updateStockBasedOnTransaction(StockTransaction transaction);
  Future<double> getCurrentStock(String stockId, String posId);
}
