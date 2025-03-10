import 'package:equatable/equatable.dart';

class StockTransaction extends Equatable {
  final String id;
  final String stockId;
  final String posId;
  final String user;
  final double change; // - for sale, + for restock
  final DateTime timestamp;
  final String type; // "sale", "restock", "correction"

  const StockTransaction({
    required this.id,
    required this.stockId,
    required this.posId,
    required this.user,
    required this.change,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props =>
      [id, stockId, posId, user, change, timestamp, type];
}
