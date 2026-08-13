import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/reports/data/models/report_models.dart';
import 'package:montajat_customer_app/features/reports/data/repositories/reports_repository.dart';

void main() {
  test('report run uses run_id returned by the API', () {
    final model = ReportRunModel.fromJson({
      'run_id': 3,
      'report_type': 'purchases_by_period',
      'status': 'completed',
    });

    expect(model.id, 3);
    expect(model.canDownload, isTrue);
  });

  test('report actions use the documented methods, paths, and payloads', () async {
    final api = _FakeApiConsumer();
    final repository = RemoteReportsRepository(api);

    await repository.getSavedReports();
    await repository.saveReport(name: 'Monthly', type: 'purchases');
    await repository.deleteSavedReport(7);
    await repository.getRuns();
    final download = await repository.getDownloadUrl(9);
    final result = await repository.runReport(
      'purchases_by_period',
      filters: {'from': '2026-01-01', 'to': '2026-08-13'},
    );
    await repository.exportReport(
      'purchases_by_period',
      format: 'pdf',
      filters: {'from': '2026-01-01', 'to': '2026-08-13'},
    );
    await repository.exportReport('purchases_by_period', format: 'xlsx');

    expect(api.calls, [
      'GET ${EndPoints.savedReports}',
      'POST ${EndPoints.savedReports} name=Monthly,type=purchases',
      'DELETE ${EndPoints.savedReport(7)}',
      'GET ${EndPoints.reportRuns}',
      'GET ${EndPoints.downloadReportRun(9)}',
      'GET ${EndPoints.report('purchases_by_period')}?from=2026-01-01&to=2026-08-13',
      'POST ${EndPoints.exportReport('purchases_by_period')} format=pdf,from=2026-01-01,to=2026-08-13',
      'POST ${EndPoints.exportReport('purchases_by_period')} format=xlsx,from=null,to=null',
    ]);
    expect(download.toString(), 'https://example.test/report.pdf');
    expect(result.rows.single['total'], 120);
  });

  test('shows backend validation details for a 422 response', () async {
    final repository = RemoteReportsRepository(_ValidationApiConsumer());

    expect(
      () => repository.runReport('purchases'),
      throwsA(
        isA<ReportsException>().having(
          (error) => error.messageKey,
          'message',
          'The from field is required.',
        ),
      ),
    );
  });
}

class _FakeApiConsumer implements ApiConsumer {
  final List<String> calls = [];

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    calls.add('GET $path');
    if (path == EndPoints.savedReports) {
      return http.Response('{"success":true,"data":[]}', 200);
    }
    if (path == EndPoints.reportRuns) {
      return http.Response('{"success":true,"data":[]}', 200);
    }
    if (path == EndPoints.downloadReportRun(9)) {
      return http.Response(
        '{"success":true,"data":{"download_url":"https://example.test/report.pdf"}}',
        200,
      );
    }
    return http.Response(
      '{"success":true,"data":{"rows":[{"total":120}]}}',
      200,
    );
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    if (path == EndPoints.savedReports) {
      calls.add('POST $path name=${body?['name']},type=${body?['type']}');
    } else {
      final filters = body?['filters'] as Map<String, dynamic>?;
      calls.add(
        'POST $path format=${body?['format']},from=${filters?['from']},to=${filters?['to']}',
      );
    }
    return http.Response('{"success":true,"data":{}}', 200);
  }

  @override
  Future<http.Response> delete(
    String path,
    Map<String, String>? headers,
  ) async {
    calls.add('DELETE $path');
    return http.Response('', 204);
  }

  @override
  Future<http.Response> patch(
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
  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
}

class _ValidationApiConsumer extends _FakeApiConsumer {
  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async =>
      http.Response(
        '{"success":false,"message":"Validation failed",'
        '"errors":{"from":["The from field is required."]}}',
        422,
      );
}
