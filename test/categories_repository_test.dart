import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';

void main() {
  test('loads the category dimension from the B2B endpoint', () async {
    final consumer = _FakeApiConsumer(
      http.Response(
        '{"success":true,"data":{"department":[],"category":['
        '{"value":"Food","product_count":1147,'
        '"filter":{"category":"Food"}}],"product_type":[],"animal":[]}}',
        200,
      ),
    );

    final result = await RemoteCategoriesRepository(consumer).getCategories();

    expect(consumer.lastPath, EndPoints.categories);
    expect(result.single.value, 'Food');
    expect(result.single.productCount, 1147);
    expect(result.single.labelKey, 'categories.food');
  });

  test('rejects a response without the category dimension', () async {
    final repository = RemoteCategoriesRepository(
      _FakeApiConsumer(http.Response('{"success":true,"data":{}}', 200)),
    );

    expect(
      repository.getCategories,
      throwsA(
        isA<CategoriesException>().having(
          (error) => error.messageKey,
          'messageKey',
          'auth_errors.invalid_response',
        ),
      ),
    );
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
