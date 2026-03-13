import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../scan/domain/entities/receipt_item.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(const ReviewState()) {
    on<InitializeReview>(_onInitialize);
    on<EditItemEvent>(_onEditItem);
    on<AddItemEvent>(_onAddItem);
    on<RemoveItemEvent>(_onRemoveItem);
    on<UpdateTaxEvent>(_onUpdateTax);
    on<UpdateServiceEvent>(_onUpdateService);
    on<ConfirmReviewEvent>(_onConfirm);
  }

  void _onInitialize(InitializeReview event, Emitter<ReviewState> emit) {
    emit(state.copyWith(items: event.items, isConfirmed: false));
  }

  void _onEditItem(EditItemEvent event, Emitter<ReviewState> emit) {
    final updatedItems = state.items.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onAddItem(AddItemEvent event, Emitter<ReviewState> emit) {
    emit(state.copyWith(items: [...state.items, event.item]));
  }

  void _onRemoveItem(RemoveItemEvent event, Emitter<ReviewState> emit) {
    final updatedItems = state.items.where((item) => item.id != event.itemId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateTax(UpdateTaxEvent event, Emitter<ReviewState> emit) {
    emit(state.copyWith(tax: event.tax));
  }

  void _onUpdateService(UpdateServiceEvent event, Emitter<ReviewState> emit) {
    emit(state.copyWith(service: event.service));
  }

  void _onConfirm(ConfirmReviewEvent event, Emitter<ReviewState> emit) {
    emit(state.copyWith(isConfirmed: true));
  }
}
