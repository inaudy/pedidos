import '../repositories/stock_repository.dart';
import '../entities/stock_item.dart';

class GetStock {
  final StockRepository repository;

  GetStock(this.repository);

  Future<List<StockItem>> call(String posId) async {
    return await repository.getAllStock(posId);
  }
}
