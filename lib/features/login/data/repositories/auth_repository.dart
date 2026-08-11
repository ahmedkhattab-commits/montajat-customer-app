import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/features/login/data/models/auth_session_model.dart';

abstract interface class AuthRepository {
  Future<void> requestOtp(String mobile);

  Future<AuthSessionModel> verifyOtp({
    required String mobile,
    required String code,
  });

  Future<bool> hasActiveSession();
}

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<void> requestOtp(String mobile) async {
    final response = await _post(
      EndPoints.requestOtp,
      body: {'mobile': mobile},
    );
    _ensureSuccessful(response);
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String mobile,
    required String code,
  }) async {
    final response = await _post(
      EndPoints.verifyOtp,
      body: {'mobile': mobile, 'code': code},
    );
    final json = _ensureSuccessful(response);
    final session = AuthSessionModel.fromJson(json, mobile: mobile);
    await _saveSession(session);
    return session;
  }

  @override
  Future<bool> hasActiveSession() async {
    try {
      return (await CacheHelper.getSecuredString(
        ConstantKeys.accessToken,
      )).isNotEmpty;
    } on Object {
      return false;
    }
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _apiConsumer
          .post(path, body, null)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const AuthException('auth_errors.timeout');
    } on http.ClientException {
      throw const AuthException('auth_errors.network');
    }
  }

  Map<String, dynamic> _ensureSuccessful(http.Response response) {
    final json = _decodeBody(response.body);
    final isHttpSuccess =
        response.statusCode >= 200 && response.statusCode < 300;
    if (isHttpSuccess && json['success'] != false) return json;

    throw AuthException(_extractErrorMessage(json, response.statusCode));
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) return const {};
    try {
      final value = jsonDecode(body);
      if (value is Map<String, dynamic>) return value;
    } on FormatException {
      throw const AuthException('auth_errors.invalid_response');
    }
    throw const AuthException('auth_errors.invalid_response');
  }

  String _extractErrorMessage(Map<String, dynamic> json, int statusCode) {
    final error = json['error'];
    if (error is Map<String, dynamic>) {
      final fields = error['fields'];
      if (fields is Map<String, dynamic>) {
        for (final value in fields.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
        }
      }
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
    }

    return switch (statusCode) {
      429 => 'auth_errors.too_many_requests',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }

  Future<void> _saveSession(AuthSessionModel session) async {
    await CacheHelper.setSecuredString(
      ConstantKeys.accessToken,
      session.accessToken,
    );
    if (session.refreshToken != null) {
      await CacheHelper.setSecuredString(
        ConstantKeys.refreshToken,
        session.refreshToken!,
      );
    }
    await CacheHelper.setData(ConstantKeys.savePhoneToShared, session.mobile);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
