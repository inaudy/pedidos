import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedidos/core/database/app_database.dart';
import 'package:pedidos/core/network/connectivity_cubit.dart';
import 'package:pedidos/core/network/network_info.dart';
import 'package:pedidos/core/network/sync_manager.dart';
import 'package:pedidos/data/datasources/local/local_stock_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_stock_data_source.dart';
import 'package:pedidos/data/datasources/local/local_stock_transaction_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_stock_transaction_data_source.dart';
import 'package:pedidos/data/repositories/stock_repository_impl.dart';
import 'package:pedidos/data/repositories/stock_transaction_repository_impl.dart';
import 'package:pedidos/domain/usecases/get_stock.dart';
import 'package:pedidos/domain/usecases/add_stock_transaction.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_cubit.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_transaction_cubit.dart';
import 'package:pedidos/features/stock/presentation/pages/stock_page.dart';
import 'package:go_router/go_router.dart';
import 'package:pedidos/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Initialize SQLite Database using `AppDatabase`
  final database = await AppDatabase.instance.database;

  // ✅ Initialize Connectivity and NetworkInfo
  final connectivity = Connectivity();
  final networkInfo = NetworkInfo(connectivity);

  // ✅ Initialize Data Sources
  final firestore = FirebaseFirestore.instance;
  final localStockDataSource = LocalStockDataSource(database);
  final remoteStockDataSource = RemoteStockDataSource(firestore);
  final localTransactionDataSource = LocalStockTransactionDataSource(database);
  final remoteTransactionDataSource =
      RemoteStockTransactionDataSource(firestore);

  // ✅ Initialize Sync Manager
  final syncManager = SyncManager(
      networkInfo: networkInfo,
      localStockDataSource: localStockDataSource,
      remoteStockDataSource: remoteStockDataSource,
      localTransactionDataSource: localTransactionDataSource,
      remoteTransactionDataSource: remoteTransactionDataSource);

  // ✅ Initialize Repositories
  final stockRepository = StockRepositoryImpl(
      remoteDataSource: remoteStockDataSource,
      localDataSource: localStockDataSource,
      networkInfo: networkInfo,
      syncManager: syncManager);

  final stockTransactionRepository = StockTransactionRepositoryImpl(
    networkInfo: networkInfo,
    syncManager: syncManager,
    localDataSource: localTransactionDataSource,
    remoteDataSource: remoteTransactionDataSource,
  );

  // ✅ Initialize Use Cases
  final getStock = GetStock(stockRepository);
  final addStockTransaction =
      AddStockTransaction(stockTransactionRepository, stockRepository);

  // ✅ Start Syncing in Background
  //syncManager.syncStockToFirestore;
  //syncManager.syncStockFromFirestore;

  runApp(MyApp(
    networkInfo: networkInfo,
    syncManager: syncManager,
    getStock: getStock,
    addStockTransaction: addStockTransaction,
  ));
  await syncManager.initializeLocalDatabase();
}

class MyApp extends StatelessWidget {
  final GetStock getStock;
  final AddStockTransaction addStockTransaction;
  final SyncManager syncManager;
  final NetworkInfo networkInfo;

  const MyApp(
      {super.key,
      required this.syncManager,
      required this.networkInfo,
      required this.getStock,
      required this.addStockTransaction,
      required});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => ConnectivityCubit(syncManager: syncManager)),
        BlocProvider(
            create: (context) =>
                StockCubit(getStock: getStock, syncManager: syncManager)),
        BlocProvider(
            create: (context) => StockTransactionCubit(
                  stockCubit: context.read<StockCubit>(),
                  addStockTransaction: addStockTransaction,
                )),
      ],
      child: MaterialApp.router(
        title: 'Stock Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: _router,
      ),
    );
  }
}

/// ✅ App Routing with `GoRouter`
final _router = GoRouter(
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return '/login'; // ✅ Redirect to login if not authenticated
    }
    return null; // ✅ Continue normal navigation if logged in
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final userRole =
            state.extra as String? ?? "viewer"; // ✅ Default to "viewer"
        return StockPage(posId: 'beach_club', userRole: userRole);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
  ],
);
