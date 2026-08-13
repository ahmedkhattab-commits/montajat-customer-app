import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/insights/data/repositories/insights_repository.dart';

void main() {
  test('parses the insights dashboard response', () async {
    final consumer = _FakeApiConsumer(
      http.Response(
        '{"success":true,"data":{'
        '"period":{"from":"2025-08-13","to":"2026-08-13"},'
        '"summary":{"total_spend":38826.25,"invoice_count":7,'
        '"average_invoice":5546.61,"total_quantity":140,'
        '"distinct_items":2,"outstanding":34075.5,'
        '"returned_value":1800.4,"return_count":2,'
        '"return_rate_pct":4.64,"currency":"SAR"},'
        '"top_items":[{"rank":1,"item_code":"P1","name":"Product",'
        '"revenue":20257.17,"quantity":84,"purchase_count":7,'
        '"last_purchase":"2026-08-03","avg_unit_price":241.15,'
        '"share_pct":60}],'
        '"top_brands":[{"key":173,"revenue":33761.94,"quantity":140,'
        '"invoice_count":7,"item_count":2,"share_pct":100}],'
        '"top_categories":[{"key":"Treats","revenue":33761.94,'
        '"quantity":140,"invoice_count":7,"item_count":2,'
        '"share_pct":100}],'
        '"monthly":[{"key":"2026-08","revenue":4000,"quantity":20,'
        '"invoice_count":1,"item_count":2,"share_pct":11.85}],'
        '"returns":{"from":"2025-08-13","to":"2026-08-13",'
        '"invoiced_amount":38826.25,"returned_amount":1800.4,'
        '"returns_ratio_pct":4.64,"invoice_count":7,'
        '"credit_note_count":2,"monthly":[]}}}',
        200,
      ),
    );

    final insights = await RemoteInsightsRepository(
      consumer,
    ).getInsights(from: DateTime(2026, 3), to: DateTime(2026, 4, 30));

    final uri = Uri.parse(consumer.lastPath!);
    expect(uri.path, Uri.parse(EndPoints.insights).path);
    expect(uri.queryParameters['from'], '2026-03-01');
    expect(uri.queryParameters['to'], '2026-04-30');
    expect(insights.summary.totalSpend, 38826.25);
    expect(insights.topItems.single.itemCode, 'P1');
    expect(insights.monthly.single.key, '2026-08');
    expect(insights.returns.creditNoteCount, 2);
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
