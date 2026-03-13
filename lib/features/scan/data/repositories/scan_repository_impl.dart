import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/receipt_item.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/ai_parser_remote_data_source.dart';
import '../datasources/ocr_data_source.dart';

class ScanRepositoryImpl implements ScanRepository {
  final OcrDataSource ocrDataSource;
  final AiParserRemoteDataSource aiDataSource;
  final NetworkInfo networkInfo;

  ScanRepositoryImpl({
    required this.ocrDataSource,
    required this.aiDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> scanReceiptImage(String imagePath) async {
    try {
      final text = await ocrDataSource.recognizeText(imagePath);
      if (text.trim().isEmpty) {
        return const Left(ValidationFailure('No text was recognized in the image.'));
      }
      return Right(text);
    } catch (e) {
      return Left(ServerFailure('Failed to run OCR on image: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReceiptItem>>> parseReceiptText(String text) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final itemModels = await aiDataSource.parseReceiptText(text);
      if (itemModels.isEmpty) {
        return const Left(ValidationFailure('No items could be parsed from the receipt.'));
      }
      return Right(itemModels.map((model) => model.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred during parsing'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
