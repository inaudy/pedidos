import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/stock_transaction_model.dart';

class RemoteStockTransactionDataSource {
  final FirebaseFirestore firestore;

  RemoteStockTransactionDataSource(this.firestore);

  Future<List<StockTransactionModel>> getTransactionsForStock(
      String stockId, String posId) async {
    final snapshot = await firestore
        .collection('pos')
        .doc(posId) // ✅ Ensure transactions are POS-specific
        .collection('transactions')
        .where('stockId', isEqualTo: stockId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => StockTransactionModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addTransaction(StockTransactionModel transaction) async {
    try {
      print("🔥 Sending Transaction to Firestore: ${transaction.id}");
      await firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toFirestore());
      print("✅ Firestore Transaction Added: ${transaction.id}");
    } catch (e) {
      print("❌ Firestore Transaction Failed: $e");
    }
  }
}
