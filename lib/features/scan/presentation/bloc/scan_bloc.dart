import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/receipt_item.dart';
import '../../domain/usecases/parse_receipt.dart';
import '../../domain/usecases/scan_receipt.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanReceipt scanReceipt;
  final ParseReceipt parseReceipt;

  ScanBloc({
    required this.scanReceipt,
    required this.parseReceipt,
  }) : super(ScanInitial()) {
    on<ProcessImageEvent>(_onProcessImage);
  }

  Future<void> _onProcessImage(
    ProcessImageEvent event,
    Emitter<ScanState> emit,
  ) async {
    // 1. Scanning State (OCR)
    emit(const ScanProcessing(message: 'Scanning receipt...'));
    
    final scanResult = await scanReceipt(ScanReceiptParams(imagePath: event.imagePath));
    
    await scanResult.fold(
      (failure) async => emit(ScanError(message: _mapFailureToMessage(failure))),
      (recognizedText) async {
        // 2. Parsing State (AI)
        emit(const ScanProcessing(message: 'Parsing items...'));
        
        final parseResult = await parseReceipt(ParseReceiptParams(text: recognizedText));
        
        parseResult.fold(
          (failure) => emit(ScanError(message: _mapFailureToMessage(failure))),
          (items) => emit(ScanSuccess(items: items)),
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is ValidationFailure) return failure.message;
    return 'An unexpected error occurred during scanning.';
  }
}
