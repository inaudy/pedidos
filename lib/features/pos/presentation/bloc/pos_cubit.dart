import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/core/network/sync_manager.dart';
import 'package:pedidos/domain/usecases/get_pos.dart';
import 'pos_state.dart';

class PosCubit extends Cubit<PosState> {
  final GetPos getPos;
  final SyncManager syncManager;

  PosCubit({required this.getPos, required this.syncManager})
      : super(PosInitial());

  Future<void> loadPosList() async {
    emit(PosLoading());
    try {
      await syncManager.syncPosFromFirestore(); // Sync POS first
      final posList = await getPos();
      final posIds = posList.map((pos) => pos.id).toList();
      if (posIds.isEmpty) {
        emit(PosError("No POS found."));
      } else {
        emit(PosLoaded(posIds));
      }
    } catch (e) {
      emit(PosError("Failed to load POS: $e"));
    }
  }

  void selectPos(String posId) async {
    await syncManager.initializeLocalDatabase(posId);
    emit(PosSelected(posId));
  }
}
