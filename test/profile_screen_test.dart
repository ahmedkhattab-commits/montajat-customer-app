import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/config/routes/app_routes.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/features/login/data/models/auth_session_model.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';
import 'package:montajat_customer_app/features/profile/data/repositories/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    getIt.registerSingleton<ProfileRepository>(_FakeProfileRepository());
    getIt.registerSingleton<AuthRepository>(_FakeAuthRepository());
  });

  testWidgets('more navigation opens the essential profile sections', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(428, 926)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/languages',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: ScreenUtilInit(
          designSize: const Size(428, 926),
          builder: (context, _) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            onGenerateRoute: RouteGenerator.generateRoute,
            home: const Scaffold(
              bottomNavigationBar: HomeBottomNavigation(currentIndex: 0),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('home-navigation-home.navigation.more')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-screen')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-menu-profile.my_profile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-menu-profile.points')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-menu-profile.addresses')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-menu-profile.orders')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-menu-profile.reports')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-menu-profile.financial')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile-logout')), findsOneWidget);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<ProfileModel> getProfile() async => const ProfileModel(
    userId: 1,
    name: 'Ahmed',
    mobile: '966500000000',
    email: null,
    role: 'owner',
    accountName: 'Muntajat Store',
    cardCode: '555',
    city: 'Riyadh',
    country: 'Saudi Arabia',
    canPlaceOrders: true,
    canViewFinancials: true,
    credit: CreditModel(
      hasLimit: false,
      limit: null,
      used: 0,
      available: null,
      currentBalance: 0,
      openOrdersBalance: 0,
      currency: 'SAR',
      isExceeded: false,
    ),
    addressCount: 0,
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> hasActiveSession() async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestOtp(String mobile) async {}

  @override
  Future<AuthSessionModel> verifyOtp({
    required String mobile,
    required String code,
  }) async => AuthSessionModel(accessToken: 'token', mobile: mobile);
}
