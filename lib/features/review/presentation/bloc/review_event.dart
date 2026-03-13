part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class InitializeReview extends ReviewEvent {
  final List<ReceiptItem> items;
  const InitializeReview(this.items);

  @override
  List<Object> get props => [items];
}

class EditItemEvent extends ReviewEvent {
  final ReceiptItem item;
  const EditItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class AddItemEvent extends ReviewEvent {
  final ReceiptItem item;
  const AddItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveItemEvent extends ReviewEvent {
  final String itemId;
  const RemoveItemEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class UpdateTaxEvent extends ReviewEvent {
  final double tax;
  const UpdateTaxEvent(this.tax);

  @override
  List<Object> get props => [tax];
}

class UpdateServiceEvent extends ReviewEvent {
  final double service;
  const UpdateServiceEvent(this.service);

  @override
  List<Object> get props => [service];
}

class ConfirmReviewEvent extends ReviewEvent {}
