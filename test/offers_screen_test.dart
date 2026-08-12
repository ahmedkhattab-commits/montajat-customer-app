import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/config/routes/app_routes.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_api_sections.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('home shows four offers and show all opens every offer', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(428, 926)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final offers = List.generate(5, (index) => _offer(index + 1));
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
                child: HomeExpiryOffersSection(
                  section: const HomeSectionModel(
                    key: 'offers_for_you',
                    type: HomeSectionType.banners,
                    title: 'Offers for You',
                    titleEn: 'Offers for You',
                    items: [],
                  ),
                  offers: offers,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var id = 1; id <= 4; id++) {
      expect(find.byKey(ValueKey('home-expiry-offer-$id')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('home-expiry-offer-5')), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('show-all-home.offers_for_you')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('offers-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('all-offers-list')), findsOneWidget);
    for (var id = 1; id <= 5; id++) {
      expect(find.byKey(ValueKey('all-expiry-offer-$id')), findsOneWidget);
    }
  });
}

HomeExpiryOfferModel _offer(int id) => HomeExpiryOfferModel(
  offerId: id,
  itemCode: 'P$id',
  name: 'Offer $id',
  imageUrl: null,
  expiryDate: DateTime(2027),
  daysLeft: 30,
  basePrice: 10,
  offerPrice: 8,
  discountPercent: 20,
  currency: 'SAR',
  availableQuantity: 10,
  suggestedQuantity: 2,
  message: 'Offer message',
);
