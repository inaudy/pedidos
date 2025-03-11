import 'package:pedidos/core/network/network_info.dart';
import 'package:pedidos/core/network/sync_manager.dart';
import 'package:pedidos/data/datasources/local/local_pos_data_source.dart';
import 'package:pedidos/data/datasources/remote/remote_pos_data_source.dart';
import 'package:pedidos/data/models/pos_model.dart';
import 'package:pedidos/domain/entities/pos_model.dart';
import '../../domain/repositories/pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  final LocalPosDataSource localDataSource;
  final RemotePosDataSource remoteDataSource;
  final SyncManager syncManager;
  final NetworkInfo networkInfo;

  PosRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncManager,
    required this.networkInfo,
  });

  /// ✅ Get all POS, preferring local data but falling back to Firestore if needed.
  @override
  Future<List<Pos>> getAllPos() async {
    final localPosList = await localDataSource.getAllPos();

    if (localPosList.isNotEmpty) {
      return localPosList.map((model) => model.toEntity()).toList();
    }

    if (await networkInfo.isConnected) {
      final remotePosList = await remoteDataSource.getAllPos();
      for (final pos in remotePosList) {
        await localDataSource.savePos(pos);
      }
      return remotePosList.map((model) => model.toEntity()).toList();
    }

    throw Exception("No POS data available.");
  }

  /// ✅ Get a single POS by ID
  @override
  Future<Pos> getPosById(String id) async {
    final localPos = await localDataSource.getAllPos();
    final pos =
        localPos.firstWhere((p) => p.id == id, orElse: () => PosModel.empty());

    if (pos.isNotEmpty) {
      return pos.toEntity();
    }

    if (await networkInfo.isConnected) {
      final remotePos = await remoteDataSource.getPosById(id);
      if (remotePos != null) {
        await localDataSource.savePos(remotePos);
        return remotePos.toEntity();
      }
    }

    throw Exception("POS not found: $id");
  }

  /// ✅ Save POS and sync it later if offline.
  @override
  Future<void> savePos(Pos pos) async {
    final posModel = PosModel.fromEntity(pos);
    await localDataSource.savePos(posModel);
    await localDataSource.markPosAsSynced(pos.id);

    if (await networkInfo.isConnected) {
      await remoteDataSource.savePos(posModel);
    } else {
      print("⚠️ POS [$pos.id] will sync when online.");
    }
  }

  /// ✅ Delete POS both locally and remotely.
  @override
  Future<void> deletePos(String id) async {
    await localDataSource.deletePos(id);

    if (await networkInfo.isConnected) {
      await remoteDataSource.deletePos(id);
    } else {
      print("⚠️ POS [$id] deletion will sync when online.");
    }
  }

  /// ✅ Sync all POS data
  @override
  Future<void> syncPos() async {
    await syncManager.syncPosToFirestore();
    await syncManager.syncPosFromFirestore();
  }
}
