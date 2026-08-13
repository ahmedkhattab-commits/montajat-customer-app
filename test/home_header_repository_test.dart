import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_header_repository.dart';

void main() {
  test('loads store name and preferred profile address', () async {
    final consumer = _FakeApiConsumer(
      http.Response(
        '{"success":true,"data":{"account":{"name":"Store"},'
        '"addresses":[{"formatted":"First address","is_default":false},'
        '{"formatted":"Preferred address","is_default":true}]}}',
        200,
      ),
    );

    final header = await RemoteHomeHeaderRepository(consumer).getHeader();

    expect(consumer.lastPath, EndPoints.profile);
    expect(header.storeName, 'Store');
    expect(header.address, 'Preferred address');
  });

  test('uses the first address when no preferred address exists', () async {
    final repository = RemoteHomeHeaderRepository(
      _FakeApiConsumer(
        http.Response(
          '{"success":true,"data":{"account":{"name":"Store"},'
          '"addresses":[{"formatted":"First address",'
          '"is_default":false}]}}',
          200,
        ),
      ),
    );

    final header = await repository.getHeader();

    expect(header.address, 'First address');
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
