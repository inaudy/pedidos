import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/stock_item_model.dart';

class RemoteStockDataSource {
  final FirebaseFirestore firestore;

  RemoteStockDataSource(this.firestore);

  /// ✅ Fetch all stock items from Firestore
  Future<List<StockItemModel>> getAllStock(String posId) async {
    final snapshot =
        await firestore.collection('pos').doc(posId).collection('stocks').get();

    return snapshot.docs
        .map((e) => StockItemModel.fromFirestore(e.data(), e.id, posId))
        .toList();
  }

  /// ✅ Fetch a single stock item from Firestore
  Future<StockItemModel?> getStockById(String stockId, String posId) async {
    final doc = await firestore
        .collection('pos')
        .doc(posId)
        .collection('stocks')
        .doc(stockId)
        .get();

    if (doc.exists) {
      return StockItemModel.fromFirestore(doc.data()!, stockId, posId);
    }
    return null;
  }

  /// ✅ Save to Firestore only if it's newer
  Future<void> saveStockItem(StockItemModel stock) async {
    try {
      final existingDoc = await firestore
          .collection('pos')
          .doc(stock.posId)
          .collection('stocks')
          .doc(stock.stockId)
          .get();

      final remoteItem = existingDoc.exists
          ? StockItemModel.fromFirestore(
              existingDoc.data()!, stock.stockId, stock.posId)
          : null;

      if (remoteItem == null ||
          remoteItem.updatedAt.isBefore(stock.updatedAt)) {
        await firestore
            .collection('pos')
            .doc(stock.posId)
            .collection('stocks')
            .doc(stock.stockId)
            .set(stock.toFirestore());

        print("🔥 Firestore Updated: ${stock.name} - ${stock.quantity}");
      } else {
        print("⚠️ Firestore Skipped. Already up-to-date: ${stock.name}");
      }
    } catch (e) {
      print("❌ Firestore update failed: $e");
    }
  }
}
