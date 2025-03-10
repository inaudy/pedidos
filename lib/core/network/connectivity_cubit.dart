import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pedidos/core/network/sync_manager.dart';

enum ConnectivityState { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  final SyncManager syncManager;
  late StreamSubscription _connectivitySubscription;

  ConnectivityCubit({required this.syncManager})
      : super(ConnectivityState.connected) {
    _monitorConnection();
  }

  void _monitorConnection() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi)) {
          emit(ConnectivityState.connected);
          print("✅ Internet Restored. Syncing...");
          syncManager
              .syncAllPending(); // 🔄 Centralized sync for all pending updates
        } else {
          emit(ConnectivityState.disconnected);
          print("🚫 Internet Lost.");
        }
      },
    );
  }

  /// ✅ Returns `true` if online
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
