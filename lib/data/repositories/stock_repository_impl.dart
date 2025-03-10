import 'package:pedidos/core/network/network_info.dart';
import 'package:pedidos/core/network/sync_manager.dart';
import 'package:pedidos/data/models/stock_item_model.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_transaction.dart';
import '../datasources/local/local_stock_data_source.dart';
import '../datasources/remote/remote_stock_data_source.dart';

class StockRepositoryImpl implements StockRepository {
  final LocalStockDataSource localDataSource;
  final RemoteStockDataSource remoteDataSource;
  final SyncManager syncManager;
  final NetworkInfo networkInfo;

  StockRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncManager,
    required this.networkInfo,
  });

  @override
  Future<List<StockItem>> getAllStock(String posId) async {
    return (await localDataSource.getAllStock(posId))
        .map((model) => model.toEntity())
        .toList();
  }

  /// ✅ Update stock based on a transaction & mark as unsynced
  @override
  Future<void> updateStockBasedOnTransaction(
      StockTransaction transaction) async {
    print("📢 Updating stock for transaction: ${transaction.stockId}");

    // ✅ Fetch the latest local stock
    final stock = await getStockById(transaction.stockId, transaction.posId);

    final newQuantity = stock.quantity + transaction.change;
    final updatedStock = stock.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(), // ✅ Update the timestamp
    );

    await localDataSource
        .saveStockItem(StockItemModel.fromEntity(updatedStock));
    await localDataSource.markStockAsUnsynced(transaction.stockId);

    print("✅ Stock updated locally & marked as unsynced.");

    // ✅ Attempt to sync only the affected item if online
    if (await networkInfo.isConnected) {
      await syncManager.syncStockItemToFirestore(
          transaction.posId, transaction.stockId);
    }
  }

  /// ✅ Get stock (use SQLite first, fallback to Firestore)
  @override
  Future<StockItem> getStockById(String stockId, String posId) async {
    final localStock = await localDataSource.getStockById(stockId, posId);
    if (localStock != null) return localStock.toEntity();

    if (await networkInfo.isConnected) {
      return await syncManager.fetchStockFromFirestore(stockId, posId);
    }

    throw Exception("Stock item not found: $stockId");
  }

  @override
  Future<double> getCurrentStock(String stockId, String posId) async {
    final stock = await getStockById(stockId, posId);
    return stock.quantity;
  }
}
