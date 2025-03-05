import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/data/datasources/local/stock_db_helper.dart';
import 'package:pedidos/domain/usecases/import_stock_items_from_excel.dart';
import 'package:pedidos/firebase_options.dart';
import 'package:pedidos/login_page.dart';
import 'data/repositories/stock_repository_impl.dart';
import 'domain/usecases/get_stock_items.dart';
import 'features/stock/presentation/cubits/stock_cubit.dart';
import 'features/stock/presentation/pages/stock_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the sales point specific database (for example, "POS001")
  final stockDatabase = StockDataBase.getInstance('POS002');
  final stockRepository = StockRepositoryImpl(stockDatabase);

  // Create use cases
  final getStockItemsUseCase = GetStockItems(stockRepository);
  final importStockItemsFromFileUseCase =
      ImportStockItemsFromExcel(stockRepository);

  runApp(MyApp(
    getStockItemsUseCase: getStockItemsUseCase,
    importStockItemsFromFileUseCase: importStockItemsFromFileUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final GetStockItems getStockItemsUseCase;
  final ImportStockItemsFromExcel importStockItemsFromFileUseCase;

  const MyApp({
    super.key,
    required this.getStockItemsUseCase,
    required this.importStockItemsFromFileUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockCubit(
        getStockItemsUseCase: getStockItemsUseCase,
        importStockItemsFromExcelUseCase: importStockItemsFromFileUseCase,
      )..loadStockItems(),
      child: MaterialApp(
        title: 'Stock Management App',
        home: LoginPage(),
      ),
    );
  }
}
