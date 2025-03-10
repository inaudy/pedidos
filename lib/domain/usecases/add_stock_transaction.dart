import 'package:pedidos/domain/repositories/stock_repository.dart';

import '../repositories/stock_transaction_repository.dart';
import '../entities/stock_transaction.dart';

class AddStockTransaction {
  final StockTransactionRepository transactionRepository;
  final StockRepository stockRepository;

  AddStockTransaction(this.transactionRepository, this.stockRepository);

  Future<void> call(StockTransaction transaction) async {
    print("📢 Processing Transaction: ${transaction.stockId}");

    // ✅ Save the transaction first
    await transactionRepository.addTransaction(transaction);
    print("✅ Transaction Successfully Sent to Repository!");

    // ✅ Now update the stock
    await stockRepository.updateStockBasedOnTransaction(transaction);
    print("✅ Stock Updated Based on Transaction!");
  }
}
