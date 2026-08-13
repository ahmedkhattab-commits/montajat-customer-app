import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/config/routes/app_routes.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/data/repositories/brands_repository.dart';
import 'package:montajat_customer_app/features/home/logic/brands_cubit.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_api_sections.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('new arrivals shows six brands and show all opens every brand', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(428, 926)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final brands = List<HomeBrandModel>.generate(
      7,
      (index) => HomeBrandModel(
        code: '${index + 1}',
        name: 'Brand ${index + 1}',
        imageUrl: 'https://example.com/${index + 1}.png',
        productCount: 1,
      ),
    );
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
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeApiSection(
                  section: HomeSectionModel(
                    key: 'new_brands',
                    type: HomeSectionType.brands,
                    title: 'Just arrived',
                    titleEn: 'Just arrived',
                    items: brands,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var code = 1; code <= 6; code++) {
      expect(find.byKey(ValueKey('brand-products-$code')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('brand-products-7')), findsNothing);

    expect(find.byKey(const ValueKey('show-all-new_brands')), findsOneWidget);
  });

  test('brands cubit exposes the next local page', () async {
    final brands = List<HomeBrandModel>.generate(
      24,
      (index) => HomeBrandModel(
        code: '${index + 1}',
        name: 'Brand ${index + 1}',
        imageUrl: 'https://example.com/${index + 1}.png',
        productCount: index + 1,
      ),
    );

    final cubit = BrandsCubit(_FakeBrandsRepository(brands));
    await cubit.loadBrands();
    addTearDown(cubit.close);

    expect(cubit.state.visibleCount, 18);
    cubit.loadNextPage();
    expect(cubit.state.visibleCount, 24);
  });
}

class _FakeBrandsRepository implements BrandsRepository {
  const _FakeBrandsRepository(this.brands);

  final List<HomeBrandModel> brands;

  @override
  Future<List<HomeBrandModel>> getBrands() async => brands;
}
