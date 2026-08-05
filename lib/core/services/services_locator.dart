import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/app_interceptor.dart';
import 'package:montajat_customer_app/core/api/http_consumer.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';

final GetIt getIt = GetIt.instance;

abstract final class ServicesLocator {
  static Future<void> init() async {
    if (getIt.isRegistered<http.Client>()) return;

    getIt
      ..registerLazySingleton<AppConstant>(AppConstant.new)
      ..registerLazySingleton<AppInterceptor>(AppInterceptor.new)
      ..registerLazySingleton<http.Client>(http.Client.new)
      ..registerLazySingleton<ApiConsumer>(() => HttpConsumer(getIt()))
      ..registerLazySingleton<FlutterSecureStorage>(FlutterSecureStorage.new)
      ..registerLazySingleton<LocalAuthentication>(LocalAuthentication.new)
      ..registerLazySingleton<DeviceInfoPlugin>(DeviceInfoPlugin.new);
  }
}
