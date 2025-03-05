import 'package:pedidos/domain/entities/stock_item.dart';

class StockItemModel extends StockItem {
  const StockItemModel({
    required super.name,
    required super.quantity,
    required super.category,
    required super.unit,
    required super.lot,
    required super.min,
    required super.max,
    super.transfer,
    super.barcode,
    super.error = null,
  });

  /// Creates a `StockItem` from a Map safely
  factory StockItemModel.fromMap(Map<String, dynamic> map) {
    return StockItemModel(
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Uncategorized',
      unit: map['unit'] ?? 'unit',
      lot: map['lot'] ?? 0,
      min: (map['min'] as num?)?.toDouble() ?? 0.0,
      max: (map['max'] as num?)?.toDouble() ?? 0.0,
      transfer: map['trasnfer'],
      barcode: map['barcode'],
      error: (map['error'] as num?)?.toDouble() ?? 0.0, // Defaults to 0.0
    );
  }

  /// Creates a Map from a `StockItem`
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'unit': unit,
      'lot': lot,
      'min': min,
      'max': max,
      'transfer': transfer,
      'barcode': barcode,
      'error': error,
    };
  }
}
