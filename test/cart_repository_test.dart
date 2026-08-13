import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/cart/data/repositories/cart_repository.dart';

void main() {
  test('loads cart and maps items, delivery, and summary', () async {
    final consumer = _FakeApiConsumer();

    final cart = await RemoteCartRepository(consumer).getCart();

    expect(consumer.lastMethod, 'GET');
    expect(consumer.lastPath, EndPoints.cart);
    expect(cart.items.single.itemCode, 'P10000001');
    expect(cart.items.single.quantity, 2);
    expect(cart.itemsCount, 2);
    expect(cart.shipToCode, '7');
    expect(cart.total, 40);
  });

  test(
    'uses the documented methods and request fields for mutations',
    () async {
      final consumer = _FakeApiConsumer();
      final repository = RemoteCartRepository(consumer);

      await repository.addItem(itemCode: 'P10000001', quantity: 2);
      expect(consumer.lastMethod, 'POST');
      expect(consumer.lastPath, EndPoints.cartItems);
      expect(consumer.lastBody, {'item_code': 'P10000001', 'quantity': 2});

      await repository.updateItem(itemCode: 'P10000001', quantity: 3);
      expect(consumer.lastMethod, 'PATCH');
      expect(consumer.lastPath, EndPoints.cartItem('P10000001'));
      expect(consumer.lastBody, {'quantity': 3});

      await repository.removeItem('P10000001');
      expect(consumer.lastMethod, 'DELETE');
      expect(consumer.lastPath, EndPoints.cartItem('P10000001'));

      await repository.clearCart();
      expect(consumer.lastMethod, 'DELETE');
      expect(consumer.lastPath, EndPoints.cart);

      await repository.updateDelivery(
        shipToCode: '7',
        requestedDeliveryDate: DateTime(2026, 8, 15),
        deliveryNotes: 'Morning',
      );
      expect(consumer.lastMethod, 'PATCH');
      expect(consumer.lastPath, EndPoints.cart);
      expect(consumer.lastBody, {
        'ship_to_code': '7',
        'requested_delivery_date': '2026-08-15',
        'notes': 'Morning',
      });
    },
  );

  test('cart count is the sum of quantities, not API line count', () async {
    final consumer = _FakeApiConsumer(
      cartBodyOverride: jsonEncode({
        'success': true,
        'data': {
          'lines': [
            {
              'item_code': 'P10000001',
              'name': 'Product',
              'quantity': 3,
              'unit_price': 20,
            },
            {
              'item_code': 'P10000002',
              'name': 'Product 2',
              'quantity': 2,
              'unit_price': 10,
            },
          ],
          'meta': {},
          'totals': {'item_count': 2, 'grand_total': 80},
        },
      }),
    );

    final cart = await RemoteCartRepository(consumer).getCart();

    expect(cart.itemsCount, 5);
  });

  test('uses item code when the backend returns a null product name', () async {
    final consumer = _FakeApiConsumer(
      cartBodyOverride: jsonEncode({
        'success': true,
        'data': {
          'lines': [
            {
              'item_code': 'P16100035',
              'name': null,
              'quantity': 1,
              'unit_price': 0,
              'line_total': 0,
              'uom': '',
            },
          ],
          'meta': {},
          'totals': {
            'item_count': 1,
            'subtotal': 0,
            'vat': 0,
            'grand_total': 0,
            'currency': 'SAR',
          },
        },
      }),
    );

    final cart = await RemoteCartRepository(consumer).getCart();

    expect(cart.items.single.name, 'P16100035');
    expect(cart.itemsCount, 1);
  });
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer({this.cartBodyOverride});

  final String? cartBodyOverride;
  String? lastMethod;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  static final cartBody = jsonEncode({
    'success': true,
    'data': {
      'lines': [
        {
          'item_code': 'P10000001',
          'name': 'Product',
          'name_en': 'Product',
          'image_url': 'https://example.com/product.png',
          'uom': 'PC',
          'units_per_carton': 6,
          'quantity': 2,
          'unit_price': 20,
          'line_total': 40,
          'currency': 'SAR',
        },
      ],
      'meta': {
        'ship_to_code': '7',
        'requested_delivery_date': '2026-08-15',
        'notes': 'Morning',
      },
      'totals': {
        'item_count': 2,
        'subtotal': 40,
        'vat': 0,
        'grand_total': 40,
        'currency': 'SAR',
      },
    },
  });

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    lastMethod = 'GET';
    lastPath = path;
    return http.Response(cartBodyOverride ?? cartBody, 200);
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    lastMethod = 'POST';
    lastPath = path;
    lastBody = body;
    return http.Response('{"success":true}', 200);
  }

  @override
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    lastMethod = 'PATCH';
    lastPath = path;
    lastBody = body;
    return http.Response('{"success":true}', 200);
  }

  @override
  Future<http.Response> delete(
    String path,
    Map<String, String>? headers,
  ) async {
    lastMethod = 'DELETE';
    lastPath = path;
    lastBody = null;
    return http.Response('{"success":true}', 200);
  }

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
