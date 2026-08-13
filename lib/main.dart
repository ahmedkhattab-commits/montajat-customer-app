import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/services/firebase_notification_service.dart';
import 'package:montajat_customer_app/core/services/local_notification_service.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/firebase_options.dart';
import 'package:montajat_customer_app/my_app.dart';
import 'package:montajat_customer_app/observer.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await LocalNotificationService.init();
    await FirebaseNotificationService.init();
  } on Object catch (error) {
    debugPrint('Notification initialization skipped: $error');
  }

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
