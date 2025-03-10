import '../entities/stock_transaction.dart';

abstract class StockTransactionRepository {
  Future<void> addTransaction(StockTransaction transaction);
}
