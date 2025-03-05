import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pedidos/domain/entities/stock_item.dart';
import 'package:pedidos/domain/usecases/get_stock_items.dart';
import 'package:pedidos/domain/usecases/import_stock_items_from_excel.dart';

part 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final GetStockItems getStockItemsUseCase;
  final ImportStockItemsFromExcel importStockItemsFromExcelUseCase;

  StockCubit(
      {required this.getStockItemsUseCase,
      required this.importStockItemsFromExcelUseCase})
      : super(StockInitial());

  //Load stock items from the database
  Future<void> loadStockItems() async {
    emit(StockLoading());
    try {
      final items = await getStockItemsUseCase();
      emit(StockLoaded(items: items));
    } catch (e) {
      emit(StockError(message: e.toString()));
    }
  }

  //Import stock items from an excel file
  Future<void> importStockFromExcel(
      String fileExtension, List<int> fileBytes) async {
    try {
      await importStockItemsFromExcelUseCase(
          fileExtension: fileExtension, fileBytes: fileBytes);
      await loadStockItems(); //Reload the stock items after importing
    } catch (e) {
      emit(StockError(message: 'Excel import error: ${e.toString()}'));
    }
  }
}
