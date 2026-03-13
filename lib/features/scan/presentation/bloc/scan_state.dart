part of 'scan_bloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();
  
  @override
  List<Object> get props => [];
}

class ScanInitial extends ScanState {}

class ScanProcessing extends ScanState {
  final String message;
  const ScanProcessing({required this.message});

  @override
  List<Object> get props => [message];
}

class ScanSuccess extends ScanState {
  final List<ReceiptItem> items;
  const ScanSuccess({required this.items});

  @override
  List<Object> get props => [items];
}

class ScanError extends ScanState {
  final String message;
  const ScanError({required this.message});

  @override
  List<Object> get props => [message];
}
