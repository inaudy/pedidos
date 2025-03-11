import 'package:pedidos/domain/entities/pos_model.dart';

abstract class PosRepository {
  /// ✅ Get all POS records
  Future<List<Pos>> getAllPos();

  /// ✅ Get a single POS by ID
  Future<Pos> getPosById(String id);

  /// ✅ Save or update a POS
  Future<void> savePos(Pos pos);

  /// ✅ Delete a POS by ID
  Future<void> deletePos(String id);
}
