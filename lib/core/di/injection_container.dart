import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../network/network_info.dart';
import '../network/supabase_client.dart';

// Scan Feature
import '../../features/scan/data/datasources/ai_parser_remote_data_source.dart';
import '../../features/scan/data/datasources/ocr_data_source.dart';
import '../../features/scan/data/repositories/scan_repository_impl.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/domain/usecases/parse_receipt.dart';
import '../../features/scan/domain/usecases/scan_receipt.dart';
import '../../features/scan/presentation/bloc/scan_bloc.dart';

// Review Feature
import '../../features/review/presentation/bloc/review_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  getIt.registerLazySingleton(() => InternetConnectionChecker.instance);
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // Features - US1 Scan & Review

  // Data sources
  getIt.registerLazySingleton<OcrDataSource>(
    () => OcrDataSourceImpl(),
  );
  getIt.registerLazySingleton<AiParserRemoteDataSource>(
    () => AiParserRemoteDataSourceImpl(supabaseClient: SupabaseClientManager.client),
  );

  // Repositories
  getIt.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(
      ocrDataSource: getIt(),
      aiDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => ScanReceipt(getIt()));
  getIt.registerLazySingleton(() => ParseReceipt(getIt()));

  // Blocs
  getIt.registerFactory(() => ScanBloc(
    scanReceipt: getIt(),
    parseReceipt: getIt(),
  ));
  getIt.registerFactory(() => ReviewBloc());
}
