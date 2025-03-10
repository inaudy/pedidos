import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/core/network/sync_manager.dart';
import 'package:pedidos/domain/usecases/get_stock.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final GetStock getStock;
  final SyncManager syncManager;

  StockCubit({
    required this.getStock,
    required this.syncManager,
  }) : super(StockInitial());

  /// ✅ Load stock from SQLite **WITHOUT calling sync directly**
  Future<void> loadStock(String posId) async {
    emit(StockLoading());

    try {
      final stockItems = await getStock(posId);
      emit(StockLoaded(stockItems));
    } catch (e) {
      emit(StockError("Failed to load stock"));
    }
  }

  /// ✅ Trigger Sync when Internet is Restored
  void syncWhenOnline(String posId) {
    syncManager.syncStockFromFirestore();
  }
}
