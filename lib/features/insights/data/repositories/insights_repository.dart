import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/insights/data/models/insights_model.dart';

abstract interface class InsightsRepository {
  Future<InsightsModel> getInsights({DateTime? from, DateTime? to});
}

class RemoteInsightsRepository implements InsightsRepository {
  const RemoteInsightsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<InsightsModel> getInsights({DateTime? from, DateTime? to}) async {
    try {
      final uri = Uri.parse(EndPoints.insights).replace(
        queryParameters: {
          if (from != null) 'from': _apiDate(from),
          if (to != null) 'to': _apiDate(to),
        },
      );
      final response = await _apiConsumer
          .get(uri.toString(), null)
          .timeout(const Duration(seconds: 20));
      final value = jsonDecode(response.body);
      if (value is! Map<String, dynamic> ||
          response.statusCode < 200 ||
          response.statusCode >= 300 ||
          value['success'] != true) {
        throw InsightsException(_errorKey(response.statusCode));
      }
      return InsightsModel.fromJson(value);
    } on TimeoutException {
      throw const InsightsException('auth_errors.timeout');
    } on http.ClientException {
      throw const InsightsException('auth_errors.network');
    } on FormatException {
      throw const InsightsException('auth_errors.invalid_response');
    }
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

String _apiDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

class InsightsException implements Exception {
  const InsightsException(this.messageKey);

  final String messageKey;
}
