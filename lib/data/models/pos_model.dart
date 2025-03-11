import 'package:pedidos/domain/entities/pos_model.dart';

class PosModel extends Pos {
  const PosModel({
    required super.id,
    required super.name,
    required super.location,
    required super.synced,
  });

  /// ✅ Convert Firestore document to `PosModel`
  factory PosModel.fromFirestore(Map<String, dynamic> json, String id) {
    return PosModel(
      id: id,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      synced: json['synced'] ?? false,
    );
  }

  /// ✅ Convert SQLite row to `PosModel`
  factory PosModel.fromSQLite(Map<String, dynamic> json) {
    return PosModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      synced: json['synced'] == 1,
    );
  }

  /// ✅ Convert `PosModel` to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'synced': synced,
    };
  }

  /// ✅ Convert `PosModel` to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'synced': synced ? 1 : 0,
    };
  }

  /// ✅ Convert `PosModel` to Domain Entity
  Pos toEntity() {
    return Pos(
      id: id,
      name: name,
      location: location,
      synced: synced,
    );
  }

  /// ✅ Create an empty PosModel
  static PosModel empty() {
    return const PosModel(
      id: '',
      name: '',
      location: '',
      synced: false,
    );
  }

  /// ✅ Convert from Entity to Model
  factory PosModel.fromEntity(Pos pos) {
    return PosModel(
      id: pos.id,
      name: pos.name,
      location: pos.location,
      synced: pos.synced,
    );
  }

  /// ✅ Check if the POS is empty
  bool get isEmpty => id.isEmpty;

  /// ✅ Check if the POS is not empty
  bool get isNotEmpty => !isEmpty;
}
