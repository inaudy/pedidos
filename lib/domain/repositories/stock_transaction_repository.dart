import '../entities/stock_transaction.dart';

abstract class StockTransactionRepository {
  Future<void> addTransaction(StockTransaction transaction);
  Future<List<StockTransaction>> getTransactionsForStock(
      String stockId, String posId);
}
