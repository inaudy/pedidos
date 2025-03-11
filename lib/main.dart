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
import 'package:pedidos/data/datasources/local/local_pos_data_source.dart';
import 'package:pedidos/data/datasources/local/local_stock_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_pos_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_stock_data_source.dart';
import 'package:pedidos/data/datasources/local/local_stock_transaction_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_stock_transaction_data_source.dart';
import 'package:pedidos/data/repositories/pos_repository_impl.dart';
import 'package:pedidos/data/repositories/stock_repository_impl.dart';
import 'package:pedidos/data/repositories/stock_transaction_repository_impl.dart';
import 'package:pedidos/domain/usecases/get_pos.dart';
import 'package:pedidos/domain/usecases/get_stock.dart';
import 'package:pedidos/domain/usecases/add_stock_transaction.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_state.dart';
import 'package:pedidos/features/home/presentation/main_layout.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_cubit.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_state.dart';
import 'package:pedidos/features/pos/presentation/pages/pos_selection_page.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_cubit.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_transaction_cubit.dart';
import 'package:pedidos/features/stock/presentation/pages/stock_page.dart';
import 'package:go_router/go_router.dart';
import 'package:pedidos/features/authentication/presentation/login_page.dart';
import 'package:pedidos/features/stock/presentation/pages/upload_stock_page.dart';

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
  final localPosDataSource = LocalPosDataSource(database);
  final remotePosDataSource = RemotePosDataSource(firestore);
  final localTransactionDataSource = LocalStockTransactionDataSource(database);
  final remoteTransactionDataSource =
      RemoteStockTransactionDataSource(firestore);

  // ✅ Initialize Sync Manager
  final syncManager = SyncManager(
      networkInfo: networkInfo,
      localPosDataSource: localPosDataSource,
      remotePosDataSource: remotePosDataSource,
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

  // ✅ Initialize Repositories
  final posRepository = PosRepositoryImpl(
    localDataSource: localPosDataSource,
    remoteDataSource: remotePosDataSource,
    syncManager: syncManager,
    networkInfo: networkInfo,
  );

  final stockTransactionRepository = StockTransactionRepositoryImpl(
    networkInfo: networkInfo,
    syncManager: syncManager,
    localDataSource: localTransactionDataSource,
    remoteDataSource: remoteTransactionDataSource,
  );

  // ✅ Initialize Use Cases
  final getStock = GetStock(stockRepository);
  final getPos = GetPos(posRepository);
  final addStockTransaction =
      AddStockTransaction(stockTransactionRepository, stockRepository);

  // ✅ Start Syncing in Background
  //syncManager.syncStockToFirestore;
  //syncManager.syncStockFromFirestore;

  runApp(MyApp(
    networkInfo: networkInfo,
    syncManager: syncManager,
    getStock: getStock,
    getPos: getPos,
    addStockTransaction: addStockTransaction,
  ));
}

class MyApp extends StatelessWidget {
  final GetStock getStock;
  final GetPos getPos;
  final AddStockTransaction addStockTransaction;
  final SyncManager syncManager;
  final NetworkInfo networkInfo;

  const MyApp(
      {super.key,
      required this.syncManager,
      required this.networkInfo,
      required this.getPos,
      required this.getStock,
      required this.addStockTransaction,
      required});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => PosCubit(getPos: getPos, syncManager: syncManager)),
        BlocProvider(
          create: (_) => AuthCubit(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          )..checkAuthStatus(),
        ),
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
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final authState = context.watch<AuthCubit>().state;
        final posState = context.watch<PosCubit>().state;

        if (authState is AuthAuthenticated) {
          if (posState is PosSelected) {
            context.go('/stock');
            return const SizedBox(); // Placeholder while navigating
          } else {
            return PosSelectionPage();
          }
        } else if (authState is AuthUnauthenticated) {
          return const LoginPage();
        } else if (authState is AuthError) {
          return Center(child: Text("Error: ${authState.message}"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/stock',
          builder: (context, state) => const StockPage(),
        ),
        GoRoute(
          path: '/refill',
          builder: (context, state) =>
              const Center(child: Text("Refill Page (Coming Soon)")),
        ),
        GoRoute(
          path: '/transfers',
          builder: (context, state) =>
              const Center(child: Text("Transfers Page (Coming Soon)")),
        ),
      ],
    ),
  ],
);
