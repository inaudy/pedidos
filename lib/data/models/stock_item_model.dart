import '../../domain/entities/stock_item.dart';

class StockItemModel extends StockItem {
  const StockItemModel({
    required super.stockId,
    required super.posId,
    required super.name,
    required super.quantity,
    required super.bottleSize,
    required super.category,
    required super.unit,
    required super.packing,
    required super.min,
    required super.max,
    super.transfer,
    super.barcode,
    super.error = 0.0,
    required super.updatedAt,
  });

  /// ✅ Convert Firestore document to `StockItemModel`
  factory StockItemModel.fromFirestore(
      Map<String, dynamic> json, String id, String posId) {
    return StockItemModel(
      stockId: id,
      posId: posId,
      name: json['name'] ?? 'Unknown',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      bottleSize: (json['bottleSize'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Uncategorized',
      unit: json['unit'] ?? '',
      packing: json['packing'] ?? '',
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
      transfer: json['transfer'],
      barcode: json['barcode'],
      error: (json['error'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json.containsKey('updatedAt')
          ? DateTime.parse(json['updatedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// ✅ Convert `StockItemModel` to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "quantity": quantity,
      "bottleSize": bottleSize,
      "category": category,
      "unit": unit,
      "packing": packing,
      "min": min,
      "max": max,
      "transfer": transfer,
      "barcode": barcode,
      "error": error,
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  /// ✅ Convert SQLite row to `StockItemModel`
  factory StockItemModel.fromSQLite(Map<String, dynamic> json) {
    return StockItemModel(
      stockId: json['stockId'] ?? '',
      posId: json['posId'] ?? '',
      name: json['name'] ?? 'Unknown',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      bottleSize: (json['bottleSize'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Uncategorized',
      unit: json['unit'] ?? '',
      packing: json['packing'] ?? '',
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
      transfer: json['transfer'],
      barcode: json['barcode'],
      error: (json['error'] as num?)?.toDouble() ?? 0.0,
      updatedAt:
          json['updatedAt'] != null && json['updatedAt'].toString().isNotEmpty
              ? DateTime.tryParse(json['updatedAt']) ??
                  DateTime.fromMillisecondsSinceEpoch(0)
              : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// ✅ Convert `StockItemModel` to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      "stockId": stockId,
      "posId": posId,
      "name": name,
      "quantity": quantity,
      "bottleSize": bottleSize,
      "category": category,
      "unit": unit,
      "packing": packing,
      "min": min,
      "max": max,
      "transfer": transfer,
      "barcode": barcode,
      "error": error,
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  /// ✅ Create an empty StockItemModel (For safe operations)
  static StockItemModel empty() {
    return StockItemModel(
      stockId: '',
      posId: '',
      name: 'Empty',
      quantity: 0.0,
      bottleSize: 0.0,
      category: '',
      unit: '',
      packing: '',
      min: 0.0,
      max: 0.0,
      transfer: '',
      barcode: '',
      error: 0.0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  StockItem toEntity() {
    return StockItem(
      stockId: stockId,
      posId: posId,
      name: name,
      quantity: quantity,
      bottleSize: bottleSize,
      category: category,
      unit: unit,
      packing: packing,
      min: min,
      max: max,
      transfer: transfer,
      barcode: barcode,
      error: error,
      updatedAt: updatedAt,
    );
  }

  /// ✅ Check if the stock item is empty
  bool get isEmpty => stockId.isEmpty || name.isEmpty;

  /// ✅ Check if the stock item is NOT empty
  bool get isNotEmpty => !isEmpty;

  /// ✅ Convert `StockItem` entity to `StockItemModel`
  factory StockItemModel.fromEntity(StockItem entity) {
    return StockItemModel(
      stockId: entity.stockId,
      posId: entity.posId,
      name: entity.name,
      quantity: entity.quantity,
      bottleSize: entity.bottleSize,
      category: entity.category,
      unit: entity.unit,
      packing: entity.packing,
      min: entity.min,
      max: entity.max,
      transfer: entity.transfer,
      barcode: entity.barcode,
      error: entity.error,
      updatedAt: entity.updatedAt,
    );
  }
}
