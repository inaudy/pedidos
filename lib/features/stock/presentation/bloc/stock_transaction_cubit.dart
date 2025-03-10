import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/core/network/connectivity_cubit.dart';
import 'package:pedidos/domain/entities/stock_transaction.dart';
import 'package:pedidos/domain/usecases/add_stock_transaction.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_transaction_state.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_cubit.dart';

class StockTransactionCubit extends Cubit<StockTransactionState> {
  final AddStockTransaction addStockTransaction;
  final StockCubit stockCubit; // 🔄 Inject StockCubit to trigger stock updates

  StockTransactionCubit({
    required this.addStockTransaction,
    required this.stockCubit, // ✅ Pass the stock cubit for updates
  }) : super(StockTransactionInitial());

  /// ✅ Process stock transactions instead of editing stock directly
  Future<void> processTransaction({
    required String stockId,
    required String posId,
    required double change,
    required String type,
    required String user,
    required ConnectivityCubit connectivityCubit,
  }) async {
    emit(StockTransactionLoading());

    try {
      final transaction = StockTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stockId: stockId,
        posId: posId,
        user: user,
        change: change,
        timestamp: DateTime.now(),
        type: type,
      );

      // ✅ If online, sync immediately; otherwise, save locally for future sync
      await addStockTransaction(transaction);

      // ✅ Notify `StockCubit` to reload stock after transaction
      stockCubit.loadStock(posId);

      emit(StockTransactionSuccess());
    } catch (e) {
      emit(StockTransactionError("Transaction failed: $e"));
    }
  }
}
