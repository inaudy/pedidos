import 'package:pedidos/core/network/network_info.dart';
import 'package:pedidos/core/network/sync_manager.dart';
import 'package:pedidos/data/models/stock_transaction_model.dart';
import '../../domain/repositories/stock_transaction_repository.dart';
import '../../domain/entities/stock_transaction.dart';
import '../datasources/local/local_stock_transaction_data_source.dart';
import '../datasources/remote/remote_stock_transaction_data_source.dart';

class StockTransactionRepositoryImpl implements StockTransactionRepository {
  final LocalStockTransactionDataSource localDataSource;
  final RemoteStockTransactionDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncManager syncManager;

  StockTransactionRepositoryImpl({
    required this.networkInfo,
    required this.syncManager,
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// ✅ Add transaction, store it locally first, and sync when online
  @override
  Future<void> addTransaction(StockTransaction transaction) async {
    final txnModel = StockTransactionModel.fromEntity(transaction);
    await localDataSource.addTransaction(txnModel);

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addTransaction(txnModel);
        await localDataSource.markTransactionAsSynced(txnModel.id);

        // ✅ Sync **only the affected stock item** instead of syncing all stock
        await syncManager.syncStockItemToFirestore(
            transaction.posId, transaction.stockId);
      } catch (e) {
        print("🚫 Failed to sync transaction: $e");
      }
    }
  }

  /// ✅ Fetch transactions from Firestore when online, fallback to SQLite
  @override
  Future<List<StockTransaction>> getTransactionsForStock(
      String stockId, String posId) async {
    if (await networkInfo.isConnected) {
      try {
        final transactions =
            await remoteDataSource.getTransactionsForStock(stockId, posId);
        return transactions.map((model) => model.toEntity()).toList();
      } catch (e) {
        print("❌ Firestore fetch failed: $e");
      }
    }

    final transactions =
        await localDataSource.getTransactionsForStock(stockId, posId);
    return transactions.map((model) => model.toEntity()).toList();
  }
}
