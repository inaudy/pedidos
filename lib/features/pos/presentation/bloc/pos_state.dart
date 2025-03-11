abstract class PosState {}

class PosInitial extends PosState {}

class PosLoading extends PosState {}

class PosLoaded extends PosState {
  final List<String> posList;
  PosLoaded(this.posList);
}

class PosSelected extends PosState {
  final String posId;
  PosSelected(this.posId);
}

class PosError extends PosState {
  final String message;
  PosError(this.message);
}
