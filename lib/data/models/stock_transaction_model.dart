import '../../domain/entities/stock_transaction.dart';

class StockTransactionModel {
  final String id;
  final String stockId;
  final String posId;
  final String user;
  final double change;
  final DateTime timestamp;
  final String type; // "sale", "restock", "correction"

  const StockTransactionModel({
    required this.id,
    required this.stockId,
    required this.posId,
    required this.user,
    required this.change,
    required this.timestamp,
    required this.type,
  });

  /// Convert Firestore document to `StockTransactionModel`
  factory StockTransactionModel.fromFirestore(
      Map<String, dynamic> json, String id) {
    return StockTransactionModel(
      id: id,
      stockId: json['stockId'],
      posId: json['posId'],
      user: json['user'],
      change: (json['change'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }

  /// Convert `StockTransactionModel` to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      "stockId": stockId,
      "posId": posId,
      "user": user,
      "change": change,
      "timestamp": timestamp.toIso8601String(),
      "type": type,
    };
  }

  factory StockTransactionModel.fromSQLite(Map<String, dynamic> json) {
    return StockTransactionModel(
      id: json['id'],
      stockId: json['stockId'],
      posId: json['posId'],
      user: json['user'],
      change: (json['change'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }

  /// ✅ Convert `StockTransactionModel` to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      "id": id,
      "stockId": stockId,
      "posId": posId,
      "user": user,
      "change": change,
      "timestamp": timestamp.toIso8601String(),
      "type": type,
      "synced": 0, // ✅ Default value for unsynced transactions
    };
  }

  /// Convert `StockTransactionModel` to `StockTransaction` (Domain Entity)
  StockTransaction toEntity() {
    return StockTransaction(
      id: id,
      stockId: stockId,
      posId: posId,
      user: user,
      change: change,
      timestamp: timestamp,
      type: type,
    );
  }

  /// Convert `StockTransaction` entity to `StockTransactionModel`
  factory StockTransactionModel.fromEntity(StockTransaction entity) {
    return StockTransactionModel(
      id: entity.id,
      stockId: entity.stockId,
      posId: entity.posId,
      user: entity.user,
      change: entity.change,
      timestamp: entity.timestamp,
      type: entity.type,
    );
  }
}
