import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/payments/data/models/online_payment_models.dart';

abstract interface class OnlinePaymentsRepository {
  Future<List<OnlinePaymentMethodModel>> getMethods({
    required num amount,
    required String currency,
  });

  Future<OnlinePaymentModel> createOrderPayment({
    required String orderNumber,
    required String paymentMethodCode,
    required String channel,
  });

  Future<OnlinePaymentSessionModel> createSession(String reference);

  Future<OnlinePaymentModel> executePayment({
    required String reference,
    required String sessionId,
  });

  Future<OnlinePaymentModel> getPayment(String reference);
}

class RemoteOnlinePaymentsRepository implements OnlinePaymentsRepository {
  const RemoteOnlinePaymentsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<OnlinePaymentMethodModel>> getMethods({
    required num amount,
    required String currency,
  }) async {
    final uri = Uri.parse(EndPoints.onlinePaymentMethods).replace(
      queryParameters: {
        'amount': amount.toStringAsFixed(2),
        'currency': currency.toUpperCase(),
      },
    );
    final json = await _request(() => _apiConsumer.get(uri.toString(), null));
    final data = json['data'];
    final rawMethods = data is List
        ? data
        : data is Map<String, dynamic>
        ? data['methods']
        : null;
    if (rawMethods is! List) {
      throw const FormatException('payment methods data must be an array');
    }
    return rawMethods
        .whereType<Map>()
        .map((item) => OnlinePaymentMethodModel.fromJson(item.cast()))
        .toList(growable: false);
  }

  @override
  Future<OnlinePaymentModel> createOrderPayment({
    required String orderNumber,
    required String paymentMethodCode,
    required String channel,
  }) async {
    if (!_supportedPaymentMethodCodes.contains(
      paymentMethodCode.toLowerCase(),
    )) {
      throw const OnlinePaymentException('payments.method_unavailable');
    }
    final json = await _request(
      () => _apiConsumer.post(EndPoints.payOrder(orderNumber), {
        'gateway': 'myfatoorah',
        'channel': channel,
      }, null),
    );
    return OnlinePaymentModel.fromJson(_data(json));
  }

  @override
  Future<OnlinePaymentSessionModel> createSession(String reference) async {
    final json = await _request(
      () => _apiConsumer.post(EndPoints.paymentSession(reference), null, null),
    );
    return OnlinePaymentSessionModel.fromJson(_data(json));
  }

  @override
  Future<OnlinePaymentModel> executePayment({
    required String reference,
    required String sessionId,
  }) async {
    try {
      final json = await _request(
        () => _apiConsumer.post(EndPoints.executePayment(reference), {
          'session_id': sessionId,
        }, null),
      );
      return OnlinePaymentModel.fromJson(_data(json));
    } on OnlinePaymentException catch (error) {
      if (error.messageKey == 'auth_errors.timeout' ||
          error.code == 'PAYMENT_ALREADY_EXECUTED' ||
          error.code == 'PAYMENT_NOT_OPEN') {
        return getPayment(reference);
      }
      rethrow;
    }
  }

  @override
  Future<OnlinePaymentModel> getPayment(String reference) async {
    final json = await _request(
      () => _apiConsumer.get(EndPoints.paymentDetails(reference), null),
    );
    return OnlinePaymentModel.fromJson(_data(json));
  }

  Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const FormatException('payment data must be an object');
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid payment response');
      }
      final json = decoded.cast<String, dynamic>();
      _logResponse(response, json);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw OnlinePaymentException(
          _errorMessage(response.statusCode, json),
          code: _errorCode(json),
          statusCode: response.statusCode,
        );
      }
      return json;
    } on TimeoutException {
      throw const OnlinePaymentException('auth_errors.timeout');
    } on http.ClientException {
      throw const OnlinePaymentException('auth_errors.network');
    }
  }

  String _errorMessage(int statusCode, Map<String, dynamic> json) {
    final code = _errorCode(json);
    final mappedCode = switch (code) {
      'PAYMENT_NOT_FOUND' => 'payments.not_found',
      'PAYMENT_NOT_OPEN' ||
      'PAYMENT_ALREADY_EXECUTED' => 'payments.already_processed',
      'EMBEDDED_NOT_SUPPORTED' => 'payments.embedded_not_supported',
      'INVOICE_NOT_OPEN' => 'payments.invoice_not_open',
      'AMOUNT_EXCEEDS_INVOICE' => 'payments.amount_exceeds_invoice',
      'ORDER_ALREADY_PAID' => 'payments.order_already_paid',
      'PAYMENT_METHOD_UNAVAILABLE' => 'payments.method_unavailable',
      'GATEWAY_UNREACHABLE' => 'payments.gateway_unreachable',
      'GATEWAY_REJECTED' => 'payments.gateway_rejected',
      _ => null,
    };
    if (mappedCode != null) return mappedCode;
    final error = json['error'];
    final serverMessage = error is Map ? error['message'] : json['message'];
    if (serverMessage is String && serverMessage.trim().isNotEmpty) {
      return '${serverMessage.trim()} (HTTP $statusCode)';
    }
    return switch (statusCode) {
      404 => 'payments.not_found',
      409 => 'payments.conflict',
      422 => 'payments.invalid',
      429 => 'auth_errors.too_many_requests',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }

  String? _errorCode(Map<String, dynamic> json) {
    final error = json['error'];
    final code = error is Map ? error['code'] : json['code'];
    return code is String && code.trim().isNotEmpty ? code.trim() : null;
  }

  void _logResponse(http.Response response, Map<String, dynamic> json) {
    if (!kDebugMode) return;
    final request = response.request;
    final requestLabel = request == null
        ? 'OnlinePayments'
        : '${request.method} ${request.url}';
    debugPrint(
      '$requestLabel [HTTP ${response.statusCode}] '
      '${jsonEncode(_redactForLog(json))}',
    );
  }
}

class OnlinePaymentException implements Exception {
  const OnlinePaymentException(this.messageKey, {this.code, this.statusCode});

  final String messageKey;
  final String? code;
  final int? statusCode;
}

const _supportedPaymentMethodCodes = {'md', 'stc', 'gp', 'ap'};

const _sensitivePaymentLogKeys = {
  'authorization',
  'token',
  'api_key',
  'apikey',
  'session_id',
  'sessionid',
  'payment_url',
  'paymenturl',
  'card_number',
  'cardnumber',
  'cvc',
  'cvv',
  'otp',
};

Object? _redactForLog(Object? value) {
  if (value is Map) {
    return value.map((key, item) {
      final normalizedKey = key.toString().toLowerCase();
      return MapEntry(
        key.toString(),
        _sensitivePaymentLogKeys.contains(normalizedKey)
            ? '[REDACTED]'
            : _redactForLog(item),
      );
    });
  }
  if (value is List) return value.map(_redactForLog).toList(growable: false);
  return value;
}
