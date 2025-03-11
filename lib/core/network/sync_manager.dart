import 'package:pedidos/core/network/network_info.dart';
import 'package:pedidos/data/datasources/local/local_pos_data_source.dart';
import 'package:pedidos/data/datasources/local/local_stock_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_pos_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_stock_data_source.dart';
import 'package:pedidos/data/datasources/local/local_stock_transaction_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_stock_transaction_data_source.dart';
import 'package:pedidos/domain/entities/stock_item.dart';

class SyncManager {
  final LocalStockDataSource localStockDataSource;
  final RemoteStockDataSource remoteStockDataSource;
  final LocalStockTransactionDataSource localTransactionDataSource;
  final LocalPosDataSource localPosDataSource;
  final RemotePosDataSource remotePosDataSource;
  final RemoteStockTransactionDataSource remoteTransactionDataSource;
  final NetworkInfo networkInfo;

  SyncManager({
    required this.localStockDataSource,
    required this.remoteStockDataSource,
    required this.localTransactionDataSource,
    required this.localPosDataSource,
    required this.remotePosDataSource,
    required this.remoteTransactionDataSource,
    required this.networkInfo,
  });

  /// ✅ Initialize the local database for a selected POS
  Future<void> initializeLocalDatabase(String posId) async {
    final hasLocalData = await localStockDataSource.hasData(posId);

    if (!hasLocalData && await networkInfo.isConnected) {
      print("🆕 Initializing local database for POS: $posId...");
      final remoteStock = await remoteStockDataSource.getAllStock(posId);
      for (final stockItem in remoteStock) {
        await localStockDataSource.saveStockItem(stockItem);
      }
      print("✅ Local database initialized for POS: $posId.");
    } else {
      print("✅ Local database already initialized for POS: $posId.");
    }
  }

  /// ✅ Sync POS data from Firestore to SQLite
  Future<void> syncPosFromFirestore() async {
    if (!await networkInfo.isConnected) {
      print("🚫 No internet. Skipping POS sync.");
      return;
    }

    final remotePosList = await remotePosDataSource.getAllPos();
    for (final pos in remotePosList) {
      await localPosDataSource.savePos(pos);
    }
    print("✅ POS data synced from Firestore to SQLite.");
  }

  /// ✅ Sync all pending transactions and stock updates
  Future<void> syncAllPending() async {
    if (!await networkInfo.isConnected) {
      print("🚫 No internet. Skipping pending sync.");
      return;
    }

    print("🔄 Syncing all pending transactions and stock updates...");

    await syncTransactionsToFirestore();
    await syncStockToFirestore();
    await syncStockFromFirestore();

    print("✅ All pending sync complete.");
  }

  /// ✅ Sync transactions from SQLite to Firestore
  Future<void> syncTransactionsToFirestore() async {
    if (!await networkInfo.isConnected) {
      print("🚫 No internet. Skipping transaction sync.");
      return;
    }

    print("🔄 Syncing unsynced transactions to Firestore...");
    final localTransactions =
        await localTransactionDataSource.getUnsyncedTransactions();

    for (final transaction in localTransactions) {
      await remoteTransactionDataSource.addTransaction(transaction);
      await localTransactionDataSource.markTransactionAsSynced(transaction.id);
    }

    print(
        "✅ Transaction sync to Firestore complete. ${localTransactions.length}");
  }

  /// ✅ Sync unsynced and changed SQLite items to Firestore
  Future<void> syncStockToFirestore() async {
    if (!await networkInfo.isConnected) {
      print("🚫 No internet. Skipping sync to Firestore.");
      return;
    }

    final posIds = await _getAllPosIds();
    for (final posId in posIds) {
      print("🔄 Syncing unsynced SQLite stock to Firestore for POS: $posId...");
      final unsyncedStock = await localStockDataSource.getUnsyncedStock(posId);

      for (final localItem in unsyncedStock) {
        final remoteItem =
            await remoteStockDataSource.getStockById(localItem.stockId, posId);

        // ✅ Sync only if remote item is older or doesn't exist
        if (remoteItem == null ||
            remoteItem.updatedAt.isBefore(localItem.updatedAt)) {
          await remoteStockDataSource.saveStockItem(localItem);
          await localStockDataSource.markStockAsSynced(localItem.stockId);
          print("✅ [Firestore] Synced: ${localItem.name}");
        }
      }
    }
  }

  /// ✅ Sync Firestore stock to SQLite only if it's newer
  Future<void> syncStockFromFirestore() async {
    if (!await networkInfo.isConnected) {
      print("🚫 No internet. Skipping Firestore sync.");
      return;
    }

    final posIds = await _getAllPosIds();
    for (final posId in posIds) {
      print("🔄 Syncing Firestore stock with SQLite for POS: $posId...");
      final remoteStock = await remoteStockDataSource.getAllStock(posId);

      for (final remoteItem in remoteStock) {
        final localItem =
            await localStockDataSource.getStockById(remoteItem.stockId, posId);

        // ✅ Save only if local item is missing or outdated
        if (localItem == null ||
            localItem.updatedAt.isBefore(remoteItem.updatedAt)) {
          await localStockDataSource.saveStockItem(remoteItem);
          print("✅ [SQLite] Updated: ${remoteItem.name}");
        }
      }
    }
    print("✅ Stock sync from Firestore complete.");
  }

  /// ✅ Sync only unsynced items and update Firestore if newer
  Future<void> syncStockItemToFirestore(String posId, String stockId) async {
    if (!await networkInfo.isConnected) {
      print("🚫 No internet. Skipping sync to Firestore.");
      return;
    }

    final stock = await localStockDataSource.getStockById(stockId, posId);
    if (stock == null) {
      print("❌ Stock [$stockId] not found locally.");
      return;
    }

    final remoteStock =
        await remoteStockDataSource.getStockById(stockId, posId);

    if (remoteStock == null ||
        remoteStock.updatedAt.isBefore(stock.updatedAt)) {
      await remoteStockDataSource.saveStockItem(stock);
      await localStockDataSource.markStockAsSynced(stockId);
      print("✅ Stock item [$stockId] synced to Firestore.");
    } else {
      print(
          "⚠️ Firestore already has the latest data for [$stockId]. Skipping sync.");
    }
  }

  /// ✅ Fetch stock from Firestore and save to SQLite if it's missing
  Future<StockItem> fetchStockFromFirestore(
      String stockId, String posId) async {
    if (!await networkInfo.isConnected) {
      throw Exception("🚫 Cannot fetch from Firestore while offline.");
    }

    final stockItem = await remoteStockDataSource.getStockById(stockId, posId);
    if (stockItem != null) {
      await localStockDataSource.saveStockItem(stockItem);
      print("✅ Stock item [$stockId] fetched and saved in SQLite.");
      return stockItem.toEntity();
    } else {
      throw Exception("❌ Stock item [$stockId] not found in Firestore.");
    }
  }

  /// ✅ Sync POS data from SQLite to Firestore
  Future<void> syncPosToFirestore() async {
    final unsyncedPosList = await localPosDataSource.getUnsyncedPos();
    for (final pos in unsyncedPosList) {
      await remotePosDataSource.savePos(pos);
      await localPosDataSource.markPosAsSynced(pos.id);
    }
    print("✅ POS data synced to Firestore.");
  }

  /// ✅ Trigger sync when internet is restored
  Future<void> scheduleSyncWhenOnline() async {
    if (await networkInfo.isConnected) {
      print("🔄 Internet Restored. Syncing all pending data...");
      await syncAllPending();
    }
  }

  /// ✅ Fetch all POS IDs dynamically
  Future<List<String>> getAllPosIds() async {
    final localPosList = await localPosDataSource.getAllPos();
    return localPosList.map((pos) => pos.id).toList();
  }

  /// ✅ Fetch all POS IDs dynamically instead of hardcoding
  Future<List<String>> _getAllPosIds() async {
    return ["beach_club", "restaurant", "bar"];
  }
}
