import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/scan_repository.dart';

class ScanReceipt implements UseCase<String, ScanReceiptParams> {
  final ScanRepository repository;

  ScanReceipt(this.repository);

  @override
  Future<Either<Failure, String>> call(ScanReceiptParams params) async {
    return await repository.scanReceiptImage(params.imagePath);
  }
}

class ScanReceiptParams extends Equatable {
  final String imagePath;

  const ScanReceiptParams({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}
