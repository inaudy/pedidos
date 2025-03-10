import 'package:equatable/equatable.dart';

abstract class StockTransactionState extends Equatable {
  const StockTransactionState();

  @override
  List<Object?> get props => [];
}

class StockTransactionInitial extends StockTransactionState {}

class StockTransactionLoading extends StockTransactionState {}

class StockTransactionSuccess extends StockTransactionState {}

class StockTransactionError extends StockTransactionState {
  final String message;
  const StockTransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
