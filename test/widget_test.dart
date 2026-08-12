import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/config/routes/app_routes.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';
import 'package:montajat_customer_app/features/language_selection/data/repositories/language_repository.dart';
import 'package:montajat_customer_app/features/login/data/models/auth_session_model.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';
import 'package:montajat_customer_app/features/home/ui/home_screen.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_cubit.dart';
import 'package:montajat_customer_app/features/language_selection/ui/language_selection_screen.dart';
import 'package:montajat_customer_app/features/login/logic/login_cubit.dart';
import 'package:montajat_customer_app/features/login/logic/login_state.dart';
import 'package:montajat_customer_app/features/login/ui/login_screen.dart';
import 'package:montajat_customer_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_cubit.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_model.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/data/repositories/product_details_repository.dart';
import 'package:montajat_customer_app/features/products/data/repositories/products_repository.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_cubit.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_state.dart';
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
    if (getIt.isRegistered<CategoriesRepository>()) {
      await getIt.unregister<CategoriesRepository>();
    }
    getIt.registerLazySingleton<CategoriesRepository>(
      _FakeCategoriesRepository.new,
    );
    if (getIt.isRegistered<ProductsRepository>()) {
      await getIt.unregister<ProductsRepository>();
    }
    getIt.registerLazySingleton<ProductsRepository>(
      _FakeProductsRepository.new,
    );
    if (getIt.isRegistered<ProductDetailsRepository>()) {
      await getIt.unregister<ProductDetailsRepository>();
    }
    getIt.registerLazySingleton<ProductDetailsRepository>(
      _FakeProductDetailsRepository.new,
    );
  });

  testWidgets('shows the Stitch splash design', (tester) async {
    _usePhoneViewport(tester);
    final cubit = SplashCubit(
      shouldOpenLanguageSelection: true,
      shouldOpenOnboarding: false,
      shouldOpenLogin: false,
      hasActiveSession: () async => false,
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
          create: (_) => LoginCubit(_FakeAuthRepository()),
          child: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-logo')), findsOneWidget);
    expect(find.text('أهلاً بعودتك'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-phone-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-submit')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-create-account')), findsNothing);

    Navigator.of(tester.element(find.byType(LoginScreen))).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => HomeCubit(_FakeHomeRepository())..loadHome(),
          child: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-scroll')), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
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
    await tester.ensureVisible(find.byKey(const ValueKey('home-product-P1-0')));
    await tester.tap(find.byKey(const ValueKey('home-product-P1-0')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('product-details-screen')),
      findsOneWidget,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.fling(
      find.byKey(const ValueKey('home-scroll')),
      const Offset(0, 6000),
      3000,
    );
    await tester.pumpAndSettle();
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

    await tester.ensureVisible(
      find.byKey(const ValueKey('category-products-Food')),
    );
    await tester.tap(find.byKey(const ValueKey('category-products-Food')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('products-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('products-grid')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('products-list-view')));
    await tester.pump();
    expect(find.byKey(const ValueKey('products-list')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('product-card-P1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('product-details-screen')),
      findsOneWidget,
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

  test('opens home after restart when a secure session exists', () async {
    final cubit = SplashCubit(
      shouldOpenLanguageSelection: false,
      shouldOpenOnboarding: false,
      shouldOpenLogin: true,
      hasActiveSession: () async => true,
    );

    await cubit.start();

    final state = cubit.state as SplashCompleted;
    expect(state.shouldOpenHome, isTrue);
    expect(state.shouldOpenLogin, isFalse);
    await cubit.close();
  });

  test('validates the login phone number', () async {
    final repository = _FakeAuthRepository();
    final cubit = LoginCubit(repository);

    await cubit.submit(dialCode: '+966', phoneNumber: '12');
    expect(cubit.state, isA<LoginValidationFailure>());

    await cubit.submit(dialCode: '+966', phoneNumber: '0551234567');
    expect(cubit.state, isA<LoginOtpRequested>());
    expect(repository.requestedMobile, '+966551234567');
    await cubit.close();
  });

  test('validates the four-digit verification code', () async {
    final repository = _FakeAuthRepository();
    final cubit = VerificationCubit(repository);

    await cubit.confirm(mobile: '+966551234567', code: '12');
    expect(cubit.state, isA<VerificationValidationFailure>());

    await cubit.confirm(mobile: '+966551234567', code: '1234');
    expect(cubit.state, isA<VerificationCodeAccepted>());
    expect(repository.verifiedCode, '1234');
    await cubit.close();
  });

  test('requests a new OTP when resend becomes available', () async {
    final repository = _FakeAuthRepository();
    final cubit = VerificationCubit(repository)..startTimer(seconds: 0);

    await cubit.resend('+966551234567');

    expect(repository.requestedMobile, '+966551234567');
    expect(cubit.state, isA<VerificationResent>());
    await cubit.close();
  });

  test('updates the selected home navigation item', () async {
    final cubit = HomeCubit(_FakeHomeRepository());

    cubit.navigationSelected(1);

    expect(cubit.state.selectedNavigationIndex, 1);
    await cubit.close();
  });
}

class _FakeHomeRepository implements HomeRepository {
  @override
  Future<HomeResponseModel> getHome() async => const HomeResponseModel(
    sections: [
      HomeSectionModel(
        key: 'hero_banners',
        type: HomeSectionType.banners,
        title: null,
        titleEn: null,
        items: [
          HomeBannerModel(
            id: 1,
            title: 'Banner',
            imageUrl: 'https://example.com/banner.png',
          ),
        ],
      ),
      HomeSectionModel(
        key: 'shop_by_category',
        type: HomeSectionType.categories,
        title: 'Categories',
        titleEn: 'Categories',
        items: [HomeCategoryModel(value: 'Food', productCount: 1)],
      ),
      HomeSectionModel(
        key: 'new_brands',
        type: HomeSectionType.brands,
        title: 'Brands',
        titleEn: 'Brands',
        items: [
          HomeBrandModel(
            code: '1',
            name: 'Brand',
            imageUrl: 'https://example.com/brand.png',
            productCount: 1,
          ),
        ],
      ),
      HomeSectionModel(
        key: 'featured_products',
        type: HomeSectionType.products,
        title: 'Products',
        titleEn: 'Products',
        items: [
          HomeApiProductModel(
            itemCode: 'P1',
            name: 'منتج',
            nameEn: 'Product',
            uom: 'EA',
            unitsPerCarton: 6,
            imageUrl: null,
            unitPriceWithVat: 150,
            currency: 'SAR',
            availabilityLabel: 'متوفر',
            availabilityLabelEn: 'Available',
            canOrder: true,
          ),
        ],
      ),
    ],
  );
}

class _FakeCategoriesRepository implements CategoriesRepository {
  @override
  Future<List<CategoryModel>> getCategories() async => const [
    CategoryModel(
      value: 'Food',
      labelKey: 'categories.food',
      icon: Icons.restaurant_outlined,
      productCount: 1,
    ),
  ];
}

class _FakeProductsRepository implements ProductsRepository {
  @override
  Future<ProductsPageModel> getProducts({
    required ProductsScreenArguments filter,
    required int page,
    int perPage = 20,
    String? query,
    String? sort,
  }) async => const ProductsPageModel(
    items: [
      ProductListingItem(
        itemCode: 'P1',
        name: 'منتج',
        nameEn: 'Product',
        uom: 'EA',
        unitsPerCarton: 6,
        imageUrl: null,
        price: 150,
        currency: 'SAR',
        availabilityLabel: 'متوفر',
        availabilityLabelEn: 'Available',
        isAvailable: true,
      ),
    ],
    currentPage: 1,
    hasMore: false,
  );
}

class _FakeProductDetailsRepository implements ProductDetailsRepository {
  @override
  Future<ProductDetailsModel> getProductDetails(String itemCode) async =>
      ProductDetailsModel(
        product: const ProductListingItem(
          itemCode: 'P1',
          name: 'منتج',
          nameEn: 'Product',
          uom: 'EA',
          unitsPerCarton: 6,
          imageUrl: null,
          price: 150,
          currency: 'SAR',
          availabilityLabel: 'متوفر',
          availabilityLabelEn: 'Available',
          isAvailable: true,
        ),
        barcode: '123456',
        brandCode: '173',
        department: 'Health',
        category: 'Food',
        productType: 'Puree',
        animal: 'Cats',
        variant: null,
        unitPrice: 130,
        vatRate: 0.15,
        isDiscontinued: false,
      );
}

class _FakeAuthRepository implements AuthRepository {
  String? requestedMobile;
  String? verifiedCode;

  @override
  Future<bool> hasActiveSession() async => false;

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestOtp(String mobile) async {
    requestedMobile = mobile;
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String mobile,
    required String code,
  }) async {
    verifiedCode = code;
    return AuthSessionModel(accessToken: 'test-token', mobile: mobile);
  }
}

void _usePhoneViewport(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(428, 926)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
