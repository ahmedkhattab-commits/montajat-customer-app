import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

abstract interface class HomeRepository {
  Future<HomeResponseModel> getHome();
}

class RemoteHomeRepository implements HomeRepository {
  const RemoteHomeRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<HomeResponseModel> getHome() async {
    try {
      final response = await _apiConsumer
          .get(EndPoints.home, null)
          .timeout(const Duration(seconds: 20));
      final json = _decode(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw HomeException(_errorKey(response.statusCode));
      }

      return HomeResponseModel.fromJson(json);
    } on TimeoutException {
      throw const HomeException('auth_errors.timeout');
    } on http.ClientException {
      throw const HomeException('auth_errors.network');
    } on FormatException {
      throw const HomeException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid home response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class HomeException implements Exception {
  const HomeException(this.messageKey);

  final String messageKey;
}
