import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/receipt_item.dart';
import '../repositories/scan_repository.dart';

class ParseReceipt implements UseCase<List<ReceiptItem>, ParseReceiptParams> {
  final ScanRepository repository;

  ParseReceipt(this.repository);

  @override
  Future<Either<Failure, List<ReceiptItem>>> call(ParseReceiptParams params) async {
    return await repository.parseReceiptText(params.text);
  }
}

class ParseReceiptParams extends Equatable {
  final String text;

  const ParseReceiptParams({required this.text});

  @override
  List<Object> get props => [text];
}
