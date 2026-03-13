import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/receipt_item.dart';

abstract class ScanRepository {
  /// Scans the provided image file path using local OCR and returns the recognized text.
  Future<Either<Failure, String>> scanReceiptImage(String imagePath);
  
  /// Sends the OCR text to the AI parser and returns structured ReceiptItem objects.
  Future<Either<Failure, List<ReceiptItem>>> parseReceiptText(String text);
}
