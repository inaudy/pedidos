import 'package:pedidos/domain/entities/pos_model.dart';
import 'package:pedidos/domain/repositories/pos_repository.dart';

class GetPos {
  final PosRepository repository;

  GetPos(this.repository);

  /// ✅ Executes the retrieval of POS data
  Future<List<Pos>> call() async {
    return await repository.getAllPos();
  }
}
