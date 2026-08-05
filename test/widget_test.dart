import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/config/routes/app_routes.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/features/language_selection/data/repositories/language_repository.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';
import 'package:montajat_customer_app/features/home/ui/home_screen.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_cubit.dart';
import 'package:montajat_customer_app/features/language_selection/ui/language_selection_screen.dart';
import 'package:montajat_customer_app/features/login/logic/login_cubit.dart';
import 'package:montajat_customer_app/features/login/logic/login_state.dart';
import 'package:montajat_customer_app/features/login/ui/login_screen.dart';
import 'package:montajat_customer_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_cubit.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_cubit.dart';
import 'package:montajat_customer_app/features/splash/ui/splash_screen.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_cubit.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await ServicesLocator.init();
    await CacheHelper.init();
  });

  testWidgets('shows the Stitch splash design', (tester) async {
    _usePhoneViewport(tester);
    final cubit = SplashCubit(
      shouldOpenLanguageSelection: true,
      shouldOpenOnboarding: false,
      shouldOpenLogin: false,
    )..start();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const SplashScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('splash-design')), findsOneWidget);

    await cubit.close();
    await tester.pump(const Duration(milliseconds: 1820));
  });

  testWidgets('shows the language selection design', (tester) async {
    _usePhoneViewport(tester);
    final cubit = LanguageSelectionCubit(const LanguageRepository());

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en'), Locale('ur')],
        path: 'assets/languages',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        saveLocale: false,
        child: ScreenUtilInit(
          designSize: const Size(428, 926),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            onGenerateRoute: RouteGenerator.generateRoute,
            home: BlocProvider.value(
              value: cubit,
              child: const LanguageSelectionScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('language-logo')), findsOneWidget);
    expect(find.text('قم باختيار لغتك المفضلة'), findsOneWidget);
    expect(find.text('اللغة الإنجليزية'), findsOneWidget);

    Navigator.of(tester.element(find.byType(LanguageSelectionScreen))).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LoginCubit(),
          child: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-logo')), findsOneWidget);
    expect(find.text('أهلاً بعودتك'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-phone-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-submit')), findsOneWidget);

    Navigator.of(tester.element(find.byType(LoginScreen))).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider(create: (_) => HomeCubit(), child: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-search')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-bottom-navigation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-new-arrivals-brands')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-promo-slider'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('home-categories'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-categories'))).dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('home-new-arrivals-brands')))
            .dy,
      ),
    );
    final initialHeaderTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-top-header')))
        .dy;
    final initialBottomBarTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-bottom-navigation')))
        .dy;
    await tester.fling(
      find.byKey(const ValueKey('home-scroll')),
      const Offset(0, -6000),
      3000,
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-top-header'))).dy,
      initialHeaderTop,
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('home-bottom-navigation')))
          .dy,
      initialBottomBarTop,
    );

    await tester.fling(
      find.byKey(const ValueKey('home-scroll')),
      const Offset(0, 6000),
      3000,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('show-all-home.categories_title')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('show-all-home.categories_title')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('categories-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('categories-grid')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('standalone-categories-screen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('categories-page-search')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-top-header')), findsNothing);
    expect(find.byKey(const ValueKey('home-bottom-navigation')), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-scroll')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('home-navigation-home.navigation.categories')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('categories-scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-top-header')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-bottom-navigation')),
      findsOneWidget,
    );
    final categoriesHeaderTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-top-header')))
        .dy;
    final categoriesSearchTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-search')))
        .dy;
    await tester.fling(
      find.byKey(const ValueKey('categories-scroll')),
      const Offset(0, -500),
      1500,
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-top-header'))).dy,
      categoriesHeaderTop,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('home-search'))).dy,
      categoriesSearchTop,
    );

    await cubit.close();
  });

  test('stores the selected language in shared preferences', () async {
    const repository = LanguageRepository();

    await repository.saveLanguageCode('en');

    expect(CacheHelper.getString(ConstantKeys.selectedLanguageCode), 'en');
  });

  test('tracks onboarding page changes', () async {
    final cubit = OnboardingCubit(const OnboardingRepository());

    cubit.pageChanged(1);

    expect(cubit.state.currentPage, 1);
    await cubit.close();
  });

  test('stores onboarding completion in shared preferences', () async {
    const repository = OnboardingRepository();

    await repository.complete();

    expect(repository.isCompleted, isTrue);
  });

  test('validates the login phone number', () async {
    final cubit = LoginCubit();

    cubit.submit(dialCode: '+966', phoneNumber: '12');
    expect(cubit.state, isA<LoginValidationFailure>());

    cubit.submit(dialCode: '+966', phoneNumber: '0551234567');
    expect(cubit.state, isA<LoginReady>());
    await cubit.close();
  });

  test('validates the four-digit verification code', () async {
    final cubit = VerificationCubit();

    cubit.confirm('12');
    expect(cubit.state, isA<VerificationValidationFailure>());

    cubit.confirm('1234');
    expect(cubit.state, isA<VerificationCodeAccepted>());
    await cubit.close();
  });

  test('updates the selected home navigation item', () async {
    final cubit = HomeCubit();

    cubit.navigationSelected(1);

    expect(cubit.state.selectedNavigationIndex, 1);
    await cubit.close();
  });
}

void _usePhoneViewport(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(428, 926)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
