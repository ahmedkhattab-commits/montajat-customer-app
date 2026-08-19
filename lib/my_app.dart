import 'package:easy_localization/easy_localization.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/config/routes/app_routes.dart';
import 'package:montajat_customer_app/config/themes/app_white_theme.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_cubit.dart';
import 'package:montajat_customer_app/features/app_settings/ui/app_settings_gate.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({required this.navigateWidget, super.key});

  final String navigateWidget;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AppSettingsGate(
          child: BlocProvider.value(
            value: getIt<CartCubit>()..loadCart(),
            child: MaterialApp(
              onGenerateTitle: (context) => context.tr('app_name'),
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              theme: appWhiteTheme(),
              localizationsDelegates: [
                ...context.localizationDelegates,
                CountryLocalizations.delegate,
              ],
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              initialRoute: navigateWidget,
              onGenerateRoute: RouteGenerator.generateRoute,
            ),
          ),
        );
      },
    );
  }
}
