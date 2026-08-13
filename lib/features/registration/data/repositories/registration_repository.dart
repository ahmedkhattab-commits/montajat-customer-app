import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';

abstract interface class RegistrationRepository {
  Future<void> submit(Map<String, dynamic> data);
}

class RemoteRegistrationRepository implements RegistrationRepository {
  const RemoteRegistrationRepository(this._api);
  final ApiConsumer _api;

  @override
  Future<void> submit(Map<String, dynamic> data) async {
    try {
      final response = await _api
          .post(EndPoints.registration, data, null)
          .timeout(const Duration(seconds: 25));
      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid registration response');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw RegistrationException(_error(response.statusCode, json));
      }
    } on TimeoutException {
      throw const RegistrationException('auth_errors.timeout');
    } on http.ClientException {
      throw const RegistrationException('auth_errors.network');
    } on FormatException {
      throw const RegistrationException('auth_errors.invalid_response');
    }
  }

  String _error(int status, Map<String, dynamic> json) {
    final error = json['error'];
    final fields = error is Map ? error['fields'] : json['errors'];
    if (fields is Map) {
      for (final value in fields.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    if (error is Map && error['message'] is String) {
      return error['message'];
    }
    if (json['message'] is String) return json['message'];
    return switch (status) {
      409 => 'registration.already_exists',
      422 => 'registration.invalid_data',
      429 => 'auth_errors.too_many_requests',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }
}

class RegistrationException implements Exception {
  const RegistrationException(this.message);
  final String message;
}
