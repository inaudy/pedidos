import 'package:equatable/equatable.dart';

class StockItem extends Equatable {
  final String name;
  final double quantity;
  final String category;
  final String unit;
  final int lot;
  final double min;
  final double max;
  final String? transfer;
  final String? barcode;
  final double? error;

  const StockItem({
    required this.name,
    required this.quantity,
    required this.category,
    required this.unit,
    required this.lot,
    required this.min,
    required this.max,
    this.transfer,
    this.barcode,
    this.error = 0.0, //default prevents null issues
  });

  /// Creates a copy of this object with updated fields
  StockItem copyWith({
    String? name,
    double? quantity,
    String? category,
    String? unit,
    int? lot,
    double? min,
    double? max,
    String? transfer,
    String? barcode,
    double? error,
  }) {
    return StockItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      lot: lot ?? this.lot,
      min: min ?? this.min,
      max: max ?? this.max,
      transfer: transfer ?? this.transfer,
      barcode: barcode ?? this.barcode,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        name,
        quantity,
        category,
        unit,
        lot,
        min,
        max,
        transfer,
        barcode,
        error,
      ];
}
