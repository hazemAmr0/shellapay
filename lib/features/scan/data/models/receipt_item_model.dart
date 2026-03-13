import '../../domain/entities/receipt_item.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      id: json['id'] as String? ?? '', 
      name: json['item'] as String? ?? json['item_name'] as String? ?? 'Unknown',
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': name,
      'price': price,
    };
  }

  factory ReceiptItemModel.fromDomain(ReceiptItem entity) {
    return ReceiptItemModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
    );
  }

  ReceiptItem toDomain() {
    return ReceiptItem(
      id: id,
      name: name,
      price: price,
    );
  }
}
