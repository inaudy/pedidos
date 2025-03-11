import 'package:equatable/equatable.dart';

class Pos extends Equatable {
  final String id;
  final String name;
  final String location;
  final bool synced;

  const Pos({
    required this.id,
    required this.name,
    required this.location,
    required this.synced,
  });

  /// ✅ Create an empty POS object
  static const empty = Pos(
    id: '',
    name: '',
    location: '',
    synced: false,
  );

  /// ✅ Check if the POS is empty
  bool get isEmpty => this == Pos.empty;

  /// ✅ Check if the POS is not empty
  bool get isNotEmpty => !isEmpty;

  /// ✅ Create a copy with updated fields
  Pos copyWith({
    String? id,
    String? name,
    String? location,
    bool? synced,
  }) {
    return Pos(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [id, name, location, synced];
}
