import 'package:pedidos/domain/entities/stock_item.dart';
import 'package:pedidos/domain/repositories/stock_repository.dart';

class GetStockItems {
  final StockRepository repository;

  GetStockItems(this.repository);

  Future<List<StockItem>> call() async {
    return await repository.getAllStockItems();
  }
}
