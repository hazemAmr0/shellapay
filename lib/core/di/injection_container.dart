import 'package:get_it/get_it.dart';
import '../network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  getIt.registerLazySingleton(() => InternetConnectionChecker.instance);
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // Features
  // (Feature dependencies will be registered here as they are implemented)
}
