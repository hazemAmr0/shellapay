part of 'review_bloc.dart';

class ReviewState extends Equatable {
  final List<ReceiptItem> items;
  final double tax;
  final double service;
  final bool isConfirmed;

  const ReviewState({
    this.items = const [],
    this.tax = 0.0,
    this.service = 0.0,
    this.isConfirmed = false,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.price);
  double get total => subtotal + tax + service;

  ReviewState copyWith({
    List<ReceiptItem>? items,
    double? tax,
    double? service,
    bool? isConfirmed,
  }) {
    return ReviewState(
      items: items ?? this.items,
      tax: tax ?? this.tax,
      service: service ?? this.service,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  List<Object> get props => [items, tax, service, isConfirmed];
}
