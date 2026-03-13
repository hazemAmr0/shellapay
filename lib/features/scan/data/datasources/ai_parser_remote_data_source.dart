import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../models/receipt_item_model.dart';

abstract class AiParserRemoteDataSource {
  /// Sends raw OCR text to the Supabase Edge Function to parse into structured items
  Future<List<ReceiptItemModel>> parseReceiptText(String rawText);
}

class AiParserRemoteDataSourceImpl implements AiParserRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;

  AiParserRemoteDataSourceImpl({
    required this.supabaseClient,
    Uuid? uuidPlugin,
  }) : uuid = uuidPlugin ?? const Uuid();

  @override
  Future<List<ReceiptItemModel>> parseReceiptText(String rawText) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'parse-receipt',
        body: {'raw_text': rawText},
      );

      final data = response.data;
      if (data == null || data['items'] == null) {
        throw const ServerException('Invalid response format from AI Parser');
      }

      final itemsList = data['items'] as List;
      return itemsList.map((item) {
        final map = item as Map<String, dynamic>;
        // Ensure local ID generation if the backend doesn't provide one
        if (map['id'] == null) {
          map['id'] = uuid.v4();
        }
        return ReceiptItemModel.fromJson(map);
      }).toList();
    } on FunctionException catch (e) {
      throw ServerException('Edge Function Error: ${e.toString()}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
