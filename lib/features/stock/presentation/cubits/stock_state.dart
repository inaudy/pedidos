part of 'stock_cubit.dart';

abstract class StockState extends Equatable {
  const StockState();
  @override
  List<Object> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockItem> items;
  const StockLoaded({required this.items});

  @override
  List<Object> get props => [items];
}

class StockError extends StockState {
  final String message;
  const StockError({required this.message});

  @override
  List<Object> get props => [message];
}
