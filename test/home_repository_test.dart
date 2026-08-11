import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';

void main() {
  test('loads home sections from the authenticated B2B endpoint', () async {
    final consumer = _FakeApiConsumer(
      http.Response('{"success":true,"data":{"sections":[]}}', 200),
    );
    final repository = RemoteHomeRepository(consumer);

    final result = await repository.getHome();

    expect(consumer.lastPath, EndPoints.home);
    expect(result.sectionCount, 0);
  });

  test('rejects a malformed home response', () async {
    final repository = RemoteHomeRepository(
      _FakeApiConsumer(http.Response('{"success":true,"data":{}}', 200)),
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
  _FakeApiConsumer(this.response);

  final http.Response response;
  String? lastPath;

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    lastPath = path;
    return response;
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
