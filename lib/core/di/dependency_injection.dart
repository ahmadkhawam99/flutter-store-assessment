import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(ApiClient.createDio);
  }
}
