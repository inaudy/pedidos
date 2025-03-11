import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pos_model.dart';

class RemotePosDataSource {
  final FirebaseFirestore firestore;

  RemotePosDataSource(this.firestore);

  /// ✅ Fetch all POS from Firestore
  Future<List<PosModel>> getAllPos() async {
    final snapshot = await firestore.collection('pos').get();
    return snapshot.docs
        .map((e) => PosModel.fromFirestore(e.data(), e.id))
        .toList();
  }

  /// ✅ Save POS to Firestore
  Future<void> savePos(PosModel pos) async {
    await firestore.collection('pos').doc(pos.id).set(pos.toFirestore());
    print("✅ Firestore POS Saved: ${pos.name}");
  }

  /// ✅ Fetch a single POS by ID
  Future<PosModel?> getPosById(String id) async {
    final doc = await firestore.collection('pos').doc(id).get();
    if (doc.exists) {
      return PosModel.fromFirestore(doc.data()!, id);
    }
    return null;
  }

  Future<void> deletePos(String id) async {
    await firestore.collection('pos').doc(id).delete();
  }
}
