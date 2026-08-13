import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/reports/data/models/report_models.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class ReportsRepository {
  Future<List<SavedReportModel>> getSavedReports();
  Future<void> saveReport({
    required String name,
    required String type,
    Map<String, dynamic> filters,
  });
  Future<void> deleteSavedReport(Object id);
  Future<List<ReportRunModel>> getRuns();
  Future<Uri> getDownloadUrl(Object id);
  Future<ReportResultModel> runReport(
    String type, {
    Map<String, String> filters,
  });
  Future<void> exportReport(
    String type, {
    required String format,
    Map<String, dynamic> filters,
  });
}

class RemoteReportsRepository implements ReportsRepository {
  const RemoteReportsRepository(this._api);
  final ApiConsumer _api;

  @override
  Future<List<SavedReportModel>> getSavedReports() async => _list(
    await _request(() => _api.get(EndPoints.savedReports, null)),
    SavedReportModel.fromJson,
  );

  @override
  Future<void> saveReport({
    required String name,
    required String type,
    Map<String, dynamic> filters = const {},
  }) async {
    await _request(
      () => _api.post(EndPoints.savedReports, {
        'name': name,
        'type': type,
        'filters': filters,
      }, null),
    );
  }

  @override
  Future<void> deleteSavedReport(Object id) async {
    await _request(() => _api.delete(EndPoints.savedReport(id), null));
  }

  @override
  Future<List<ReportRunModel>> getRuns() async => _list(
    await _request(() => _api.get(EndPoints.reportRuns, null)),
    ReportRunModel.fromJson,
  );

  @override
  Future<Uri> getDownloadUrl(Object id) async {
    try {
      final response = await _api
          .get(EndPoints.downloadReportRun(id), null)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map
            ? decoded.cast<String, dynamic>()
            : <String, dynamic>{};
        throw ReportsException(_errorMessage(response.statusCode, json));
      }

      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('application/json') ||
          response.body.trimLeft().startsWith('{')) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map
            ? decoded.cast<String, dynamic>()
            : <String, dynamic>{};
        final data = _map(json['data']);
        final url = data['download_url'] ?? data['url'] ?? json['download_url'];
        if (url is String && Uri.tryParse(url)?.hasScheme == true) {
          return Uri.parse(url);
        }
        throw const ReportsException('reports.download_failed');
      }

      final directory = await getApplicationDocumentsDirectory();
      final extension = _downloadExtension(contentType);
      final file = File(
        '${directory.path}${Platform.pathSeparator}report_$id.$extension',
      );
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file.uri;
    } on TimeoutException {
      throw const ReportsException('auth_errors.timeout');
    } on http.ClientException {
      throw const ReportsException('auth_errors.network');
    } on FormatException {
      throw const ReportsException('auth_errors.invalid_response');
    }
  }

  String _downloadExtension(String contentType) {
    if (contentType.contains('pdf')) return 'pdf';
    if (contentType.contains('spreadsheetml')) return 'xlsx';
    if (contentType.contains('excel')) return 'xls';
    return 'csv';
  }

  @override
  Future<ReportResultModel> runReport(
    String type, {
    Map<String, String> filters = const {},
  }) async {
    final uri = Uri.parse(
      EndPoints.report(type),
    ).replace(queryParameters: filters.isEmpty ? null : filters);
    final json = await _request(() => _api.get(uri.toString(), null));
    final data = json['data'];
    return ReportResultModel.fromJson(
      data is Map ? data.cast<String, dynamic>() : {'data': data},
    );
  }

  @override
  Future<void> exportReport(
    String type, {
    required String format,
    Map<String, dynamic> filters = const {},
  }) async {
    await _request(
      () => _api.post(EndPoints.exportReport(type), {
        'format': format,
        'filters': filters,
      }, null),
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 30));
      if (response.body.trim().isEmpty &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        return const {};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('reports response must be an object');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw ReportsException(_errorMessage(response.statusCode, json));
      }
      return json;
    } on TimeoutException {
      throw const ReportsException('auth_errors.timeout');
    } on http.ClientException {
      throw const ReportsException('auth_errors.network');
    } on FormatException {
      throw const ReportsException('auth_errors.invalid_response');
    }
  }

  List<T> _list<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    final data = json['data'];
    final value = data is List
        ? data
        : _map(data)['items'] ?? _map(data)['data'];
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) => parser(item.cast())).toList();
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map ? value.cast<String, dynamic>() : const {};

  String _errorMessage(int statusCode, Map<String, dynamic> json) {
    final error = json['error'];
    final errorMap = _map(error);
    final fieldMessage = _firstValidationMessage(
      errorMap['fields'] ?? json['errors'],
    );
    if (fieldMessage != null) return fieldMessage;

    for (final value in [
      errorMap['message'],
      error is String ? error : null,
      json['message'],
    ]) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }

    return switch (statusCode) {
      404 => 'reports.not_found',
      422 => 'reports.invalid_filters',
      429 => 'auth_errors.too_many_requests',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }

  String? _firstValidationMessage(Object? fields) {
    if (fields is Map) {
      for (final value in fields.values) {
        final message = _firstValidationMessage(value);
        if (message != null) return message;
      }
    }
    if (fields is List) {
      for (final value in fields) {
        final message = _firstValidationMessage(value);
        if (message != null) return message;
      }
    }
    if (fields is String && fields.trim().isNotEmpty) return fields.trim();
    return null;
  }
}

class ReportsException implements Exception {
  const ReportsException(this.messageKey);
  final String messageKey;
}
