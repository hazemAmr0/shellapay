import 'package:equatable/equatable.dart';

class ReceiptItem extends Equatable {
  final String id;
  final String name;
  final double price;

  const ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];

  ReceiptItem copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}
