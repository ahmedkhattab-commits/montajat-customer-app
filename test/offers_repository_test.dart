import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/features/home/data/repositories/offers_repository.dart';

void main() {
  test('loads expiry offers using API pagination', () async {
    final consumer = _FakeApiConsumer(
      http.Response(
        '{"success":true,"data":[{"offer_id":7,'
        '"item_code":"P1","name":"Offer","image_url":null,'
        '"expiry":{"date":"2026-09-01","days_left":20},'
        '"pricing":{"base_price":7,"offer_price":6.3,'
        '"discount_pct":10,"currency":"SAR"},'
        '"quantity":{"available":40,"suggested":3},'
        '"why":{"message":"Reason"}}],'
        '"meta":{"pagination":{"current_page":2,"per_page":20,'
        '"total":8,"last_page":3,"has_more":true}}}',
        200,
      ),
    );

    final page = await RemoteOffersRepository(consumer).getOffers(page: 2);

    final uri = Uri.parse(consumer.lastPath!);
    expect(uri.queryParameters['page'], '2');
    expect(uri.queryParameters['per_page'], '20');
    expect(page.currentPage, 2);
    expect(page.hasMore, isTrue);
    expect(page.items.single.offerId, 7);
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
