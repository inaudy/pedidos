import 'package:equatable/equatable.dart';

class StockItem extends Equatable {
  final String stockId;
  final String posId;
  final String name;
  final double quantity;
  final double bottleSize;
  final String category;
  final String unit;
  final String packing;
  final double min;
  final double max;
  final String? transfer;
  final String? barcode;
  final double error;
  final DateTime updatedAt; // ✅ Used for Firestore/SQLite sync

  const StockItem({
    required this.stockId,
    required this.posId,
    required this.name,
    required this.quantity,
    required this.bottleSize,
    required this.category,
    required this.unit,
    required this.packing,
    required this.min,
    required this.max,
    this.transfer,
    this.barcode,
    this.error = 0.0,
    required this.updatedAt, // ✅ Important for data consistency
  });

  /// ✅ Allows updating only specific fields (used in BLoC/UI updates)
  StockItem copyWith({
    String? stockId,
    String? posId,
    String? name,
    double? quantity,
    double? bottleSize,
    String? category,
    String? unit,
    String? packing,
    double? min,
    double? max,
    String? transfer,
    String? barcode,
    double? error,
    DateTime? updatedAt,
  }) {
    return StockItem(
      stockId: stockId ?? this.stockId,
      posId: posId ?? this.posId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      bottleSize: bottleSize ?? this.bottleSize,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      packing: packing ?? this.packing,
      min: min ?? this.min,
      max: max ?? this.max,
      transfer: transfer ?? this.transfer,
      barcode: barcode ?? this.barcode,
      error: error ?? this.error,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ✅ Prevents `null` errors by providing a safe empty object
  static StockItem empty() {
    return StockItem(
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
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(0), // Default: very old date
    );
  }

  @override
  List<Object?> get props => [
        stockId,
        posId,
        name,
        quantity,
        bottleSize,
        category,
        unit,
        packing,
        min,
        max,
        transfer,
        barcode,
        error,
        updatedAt,
      ];
}
