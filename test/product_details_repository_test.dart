import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/products/data/repositories/product_details_repository.dart';

void main() {
  test('loads all product detail fields using the item code', () async {
    final consumer = _FakeApiConsumer(
      http.Response(
        '{"success":true,"data":{'
        '"item_code":"P10000001",'
        '"name":"Product AR","name_en":"Product EN",'
        '"barcode":"763163284075","uom":"PC",'
        '"units_per_carton":6,"brand_code":173,'
        '"image_url":"https://example.com/product.png",'
        '"classification":{"department":"Health & Wellness",'
        '"category":"Supplements & Treats","product_type":"Puree",'
        '"animal":"Cats","variant":null},'
        '"price":{"unit_price":7,"unit_price_with_vat":8.05,'
        '"vat_rate":0.15,"currency":"SAR","price_list":1},'
        '"availability":{"status":"out_of_stock",'
        '"label":"Unavailable","label_en":"Out of stock",'
        '"can_order":false},"updated_at":"2026-08-11T14:41:07+00:00",'
        '"is_discontinued":false}}',
        200,
      ),
    );

    final details = await RemoteProductDetailsRepository(
      consumer,
    ).getProductDetails('P10000001');

    expect(consumer.lastPath, EndPoints.productDetails('P10000001'));
    expect(details.product.itemCode, 'P10000001');
    expect(details.barcode, '763163284075');
    expect(details.brandCode, '173');
    expect(details.category, 'Supplements & Treats');
    expect(details.product.price, 8.05);
    expect(details.product.isAvailable, isFalse);
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
