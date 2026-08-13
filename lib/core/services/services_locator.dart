import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/app_interceptor.dart';
import 'package:montajat_customer_app/core/api/http_consumer.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/products/data/repositories/products_repository.dart';
import 'package:montajat_customer_app/features/products/data/repositories/product_details_repository.dart';
import 'package:montajat_customer_app/features/profile/data/repositories/profile_repository.dart';
import 'package:montajat_customer_app/features/addresses/data/repositories/addresses_repository.dart';
import 'package:montajat_customer_app/features/cart/data/repositories/cart_repository.dart';
import 'package:montajat_customer_app/features/orders/data/repositories/orders_repository.dart';
import 'package:montajat_customer_app/features/finance/data/repositories/finance_repository.dart';

final GetIt getIt = GetIt.instance;

abstract final class ServicesLocator {
  static Future<void> init() async {
    if (getIt.isRegistered<http.Client>()) return;

    getIt
      ..registerLazySingleton<AppConstant>(AppConstant.new)
      ..registerLazySingleton<AppInterceptor>(AppInterceptor.new)
      ..registerLazySingleton<http.Client>(http.Client.new)
      ..registerLazySingleton<ApiConsumer>(() => HttpConsumer(getIt()))
      ..registerLazySingleton<AuthRepository>(
        () => RemoteAuthRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<HomeRepository>(
        () => RemoteHomeRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<CategoriesRepository>(
        () => RemoteCategoriesRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<ProductsRepository>(
        () => RemoteProductsRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<ProductDetailsRepository>(
        () => RemoteProductDetailsRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<ProfileRepository>(
        () => RemoteProfileRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<AddressesRepository>(
        () => RemoteAddressesRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<CartRepository>(
        () => RemoteCartRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<OrdersRepository>(
        () => RemoteOrdersRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<FinanceRepository>(
        () => RemoteFinanceRepository(getIt<ApiConsumer>()),
      )
      ..registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
      )
      ..registerLazySingleton<LocalAuthentication>(LocalAuthentication.new)
      ..registerLazySingleton<DeviceInfoPlugin>(DeviceInfoPlugin.new);
  }
}
