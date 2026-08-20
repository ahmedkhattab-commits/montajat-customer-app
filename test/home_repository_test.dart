import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';

void main() {
  test('loads home sections from the authenticated B2B endpoint', () async {
    final consumer = _FakeApiConsumer(
      homeResponse: http.Response(
        '{"success":true,"data":{"sections":[]}}',
        200,
      ),
      offersResponse: http.Response('{"success":true,"data":[]}', 200),
      bannersResponse: http.Response('{"success":true,"data":[]}', 200),
    );
    final repository = RemoteHomeRepository(consumer);

    final result = await repository.getHome();

    expect(
      consumer.paths,
      containsAll([EndPoints.home, EndPoints.expiryOffers, EndPoints.banners]),
    );
    expect(result.sectionCount, 1);
    expect(result.expiryOffers, isEmpty);
  });

  test('rejects a malformed home response', () async {
    final repository = RemoteHomeRepository(
      _FakeApiConsumer(
        homeResponse: http.Response('{"success":true,"data":{}}', 200),
        offersResponse: http.Response('{"success":true,"data":[]}', 200),
        bannersResponse: http.Response('{"success":true,"data":[]}', 200),
      ),
    );

    expect(
      repository.getHome,
      throwsA(
        isA<HomeException>().having(
          (error) => error.messageKey,
          'messageKey',
          'auth_errors.invalid_response',
        ),
      ),
    );
  });

  test('loads expiry offers for the offers section', () async {
    final repository = RemoteHomeRepository(
      _FakeApiConsumer(
        homeResponse: http.Response(
          '{"success":true,"data":{"sections":[]}}',
          200,
        ),
        offersResponse: http.Response(
          '{"success":true,"data":[{"offer_id":7,'
          '"item_code":"P10000001","name":"Offer",'
          '"image_url":"https://example.com/offers/7.png",'
          '"expiry":{"date":"2026-09-01","days_left":20},'
          '"pricing":{"base_price":7,"offer_price":6.3,'
          '"discount_pct":10,"currency":"SAR"},'
          '"quantity":{"available":40,"suggested":3.35},'
          '"why":{"message":"Offer reason"}}]}',
          200,
        ),
        bannersResponse: http.Response('{"success":true,"data":[]}', 200),
      ),
    );

    final result = await repository.getHome();

    expect(result.expiryOffers.single.offerId, 7);
    expect(result.expiryOffers.single.offerPrice, 6.3);
    expect(result.expiryOffers.single.daysLeft, 20);
    expect(
      result.expiryOffers.single.imageUrl,
      'https://example.com/offers/7.png',
    );
    expect(
      result.sections.map((section) => section.key),
      contains('offers_for_you'),
    );
  });

  test('replaces home banners with the dedicated banners endpoint', () async {
    final repository = RemoteHomeRepository(
      _FakeApiConsumer(
        homeResponse: http.Response(
          '{"success":true,"data":{"sections":[{"key":"hero_banners",'
          '"type":"banners","title":null,"title_en":null,"items":[]}]}}',
          200,
        ),
        offersResponse: http.Response('{"success":true,"data":[]}', 200),
        bannersResponse: http.Response(
          '{"success":true,"data":[{"id":3,"title":"Season",'
          '"image_url":"https://example.com/banner.png",'
          '"placement":"discounts"}]}',
          200,
        ),
      ),
    );

    final result = await repository.getHome();
    final banners = result.sections.single.items.cast<HomeBannerModel>();

    expect(banners.single.id, 3);
    expect(banners.single.imageUrl, 'https://example.com/banner.png');
  });

  test('keeps offers section when replacing hero banners', () async {
    final repository = RemoteHomeRepository(
      _FakeApiConsumer(
        homeResponse: http.Response(
          '{"success":true,"data":{"sections":['
          '{"key":"hero_banners","type":"banners","title":null,'
          '"title_en":null,"items":[]},'
          '{"key":"offers_for_you","type":"banners","title":"Offers",'
          '"title_en":"Offers","items":[]}]}}',
          200,
        ),
        offersResponse: http.Response(
          '{'
          '"success":true,"data":[]}',
          200,
        ),
        bannersResponse: http.Response('{"success":true,"data":[]}', 200),
      ),
    );

    final result = await repository.getHome();

    expect(
      result.sections.map((section) => section.key),
      containsAllInOrder(['hero_banners', 'offers_for_you']),
    );
  });

  test('parses product fields used by the home design', () {
    final response = HomeResponseModel.fromJson({
      'success': true,
      'data': {
        'sections': [
          {
            'key': 'featured_products',
            'type': 'curated_products',
            'title': 'المنتجات المميزة',
            'title_en': 'Featured Products',
            'items': [
              {
                'item_code': 'P10000001',
                'name': 'منتج',
                'name_en': 'Product',
                'uom': 'PC',
                'units_per_carton': null,
                'image_url': null,
                'price': {
                  'unit_price_with_vat': 8.05,
                  'carton_price': 70,
                  'carton_price_with_vat': 80.5,
                  'currency': 'SAR',
                },
                'availability': {
                  'label': 'متوفر',
                  'label_en': 'In stock',
                  'can_order': true,
                },
              },
            ],
          },
        ],
      },
    });

    final section = response.sections.single;
    final product = section.items.single as HomeApiProductModel;
    expect(section.localizedTitle('en'), 'Featured Products');
    expect(product.localizedName('ar'), 'منتج');
    expect(product.cartonPrice, 70);
    expect(product.canOrder, isTrue);
  });
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer({
    required this.homeResponse,
    required this.offersResponse,
    required this.bannersResponse,
  });

  final http.Response homeResponse;
  final http.Response offersResponse;
  final http.Response bannersResponse;
  final List<String> paths = [];

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    paths.add(path);
    return switch (path) {
      EndPoints.expiryOffers => offersResponse,
      EndPoints.banners => bannersResponse,
      _ => homeResponse,
    };
  }

  @override
  Future<http.Response> delete(String path, Map<String, String>? headers) =>
      throw UnimplementedError();

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

  @override
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
}
