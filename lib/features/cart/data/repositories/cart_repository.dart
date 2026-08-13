import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/cart/data/models/cart_model.dart';

abstract interface class CartRepository {
  Future<CartModel> getCart();
  Future<void> addItem({required String itemCode, required int quantity});
  Future<void> updateItem({required String itemCode, required int quantity});
  Future<void> removeItem(String itemCode);
  Future<void> clearCart();
  Future<void> updateDelivery({
    required String shipToCode,
    required DateTime requestedDeliveryDate,
    String? deliveryNotes,
  });
}

class RemoteCartRepository implements CartRepository {
  const RemoteCartRepository(this._apiConsumer);
  final ApiConsumer _apiConsumer;

  @override
  Future<CartModel> getCart() async => CartModel.fromJson(
    await _request(() => _apiConsumer.get(EndPoints.cart, null)),
  );

  @override
  Future<void> addItem({required String itemCode, required int quantity}) =>
      _mutation(
        () => _apiConsumer.post(EndPoints.cartItems, {
          'item_code': itemCode,
          'quantity': quantity,
        }, null),
      );

  @override
  Future<void> updateItem({required String itemCode, required int quantity}) =>
      _mutation(
        () => _apiConsumer.patch(EndPoints.cartItem(itemCode), {
          'quantity': quantity,
        }, null),
      );

  @override
  Future<void> removeItem(String itemCode) =>
      _mutation(() => _apiConsumer.delete(EndPoints.cartItem(itemCode), null));

  @override
  Future<void> clearCart() =>
      _mutation(() => _apiConsumer.delete(EndPoints.cart, null));

  @override
  Future<void> updateDelivery({
    required String shipToCode,
    required DateTime requestedDeliveryDate,
    String? deliveryNotes,
  }) => _mutation(
    () => _apiConsumer.patch(EndPoints.cart, {
      'ship_to_code': shipToCode,
      'requested_delivery_date': _date(requestedDeliveryDate),
      if (deliveryNotes?.trim().isNotEmpty == true)
        'notes': deliveryNotes!.trim(),
    }, null),
  );

  Future<void> _mutation(Future<http.Response> Function() call) async {
    await _request(call);
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw CartException(_errorKey(response.statusCode, json));
      }
      return json;
    } on TimeoutException {
      throw const CartException('auth_errors.timeout');
    } on http.ClientException {
      throw const CartException('auth_errors.network');
    } on FormatException {
      throw const CartException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return const {'success': true};
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid cart response');
  }

  String _errorKey(int statusCode, Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return switch (statusCode) {
      401 => 'auth_errors.request_failed',
      403 => 'cart.not_allowed',
      404 => 'cart.item_not_found',
      409 => 'cart.conflict',
      422 => 'cart.invalid_data',
      429 => 'auth_errors.too_many_requests',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class CartException implements Exception {
  const CartException(this.messageKey);
  final String messageKey;
}
