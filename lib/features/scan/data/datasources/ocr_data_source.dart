import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrDataSource {
  /// Processes an image from the given path and returns recognized text
  Future<String> recognizeText(String imagePath);
}

class OcrDataSourceImpl implements OcrDataSource {
  final TextRecognizer textRecognizer;

  OcrDataSourceImpl({TextRecognizer? recognizer}) 
      : textRecognizer = recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);
      // Note: For full Arabic support, we would use TextRecognitionScript.arabic

  @override
  Future<String> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to recognize text: $e');
    }
  }
}
