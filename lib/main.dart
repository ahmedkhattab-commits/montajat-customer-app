import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/my_app.dart';
import 'package:montajat_customer_app/observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = Observer();
  await ServicesLocator.init();
  await CacheHelper.init();

  final savedLanguageCode =
      CacheHelper.getString(ConstantKeys.selectedLanguageCode) ?? 'ar';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('ur')],
      path: 'assets/languages',
      fallbackLocale: const Locale('ar'),
      startLocale: Locale(savedLanguageCode),
      child: const MyApp(navigateWidget: Routes.splashScreen),
    ),
  );
}
