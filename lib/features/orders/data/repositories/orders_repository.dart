import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';

abstract interface class OrdersRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrder(String orderNumber);
  Future<OrderModel> checkout();
  Future<OrderModel> cancelOrder(String orderNumber);
}

class RemoteOrdersRepository implements OrdersRepository {
  const RemoteOrdersRepository(this._apiConsumer);
  final ApiConsumer _apiConsumer;

  @override
  Future<List<OrderModel>> getOrders() async {
    final json = await _request(
      () => _apiConsumer.get('${EndPoints.orders}?per_page=100', null),
    );
    final data = json['data'];
    if (data is! List) {
      throw const FormatException('orders.data must be a list');
    }
    return data
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(item.cast()))
        .toList(growable: false);
  }

  @override
  Future<OrderModel> getOrder(String orderNumber) async => OrderModel.fromJson(
    _data(
      await _request(
        () => _apiConsumer.get(EndPoints.orderDetails(orderNumber), null),
      ),
    ),
  );

  @override
  Future<OrderModel> checkout() async {
    final idempotencyKey =
        'app-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    final json = await _request(
      () => _apiConsumer.post(EndPoints.orders, const {}, {
        'Idempotency-Key': idempotencyKey,
      }),
    );
    return OrderModel.fromJson(_data(json));
  }

  @override
  Future<OrderModel> cancelOrder(String orderNumber) async =>
      OrderModel.fromJson(
        _data(
          await _request(
            () => _apiConsumer.post(
              EndPoints.cancelOrder(orderNumber),
              const {},
              null,
            ),
          ),
        ),
      );

  Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const FormatException('order.data must be an object');
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 20));
      final value = jsonDecode(response.body);
      if (value is! Map) throw const FormatException('Invalid order response');
      final json = value.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw OrdersException(_errorMessage(response.statusCode, json));
      }
      return json;
    } on TimeoutException {
      throw const OrdersException('auth_errors.timeout');
    } on http.ClientException {
      throw const OrdersException('auth_errors.network');
    }
  }

  String _errorMessage(int statusCode, Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return switch (statusCode) {
      404 => 'orders.not_found',
      409 => 'orders.conflict',
      422 => 'orders.checkout_invalid',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }
}

class OrdersException implements Exception {
  const OrdersException(this.messageKey);
  final String messageKey;
}
