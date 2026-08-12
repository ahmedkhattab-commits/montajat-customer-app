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
    );
    final repository = RemoteHomeRepository(consumer);

    final result = await repository.getHome();

    expect(
      consumer.paths,
      containsAll([EndPoints.home, EndPoints.expiryOffers]),
    );
    expect(result.sectionCount, 0);
    expect(result.expiryOffers, isEmpty);
  });

  test('rejects a malformed home response', () async {
    final repository = RemoteHomeRepository(
      _FakeApiConsumer(
        homeResponse: http.Response('{"success":true,"data":{}}', 200),
        offersResponse: http.Response('{"success":true,"data":[]}', 200),
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
                'price': {'unit_price_with_vat': 8.05, 'currency': 'SAR'},
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
    expect(product.unitPriceWithVat, 8.05);
    expect(product.canOrder, isTrue);
  });
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer({required this.homeResponse, required this.offersResponse});

  final http.Response homeResponse;
  final http.Response offersResponse;
  final List<String> paths = [];

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    paths.add(path);
    return path == EndPoints.expiryOffers ? offersResponse : homeResponse;
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
