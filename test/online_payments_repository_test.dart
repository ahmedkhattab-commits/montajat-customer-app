import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/payments/data/repositories/online_payments_repository.dart';

void main() {
  test('loads hosted payment methods with the real order amount', () async {
    final consumer = _FakeApiConsumer(
      getResponse: http.Response.bytes(
        utf8.encode(
          '{"success":true,"data":[{"gateway":"myfatoorah_mada",'
          '"name_ar":"مدى","name_en":"Mada","image_url":null,'
          '"service_charge":1.5,"total_amount":101.5,"currency":"SAR"}]}',
        ),
        200,
      ),
    );
    final repository = RemoteOnlinePaymentsRepository(consumer);

    final methods = await repository.getMethods(amount: 100, currency: 'SAR');

    final uri = Uri.parse(consumer.lastGetPath!);
    expect(uri.path, Uri.parse(EndPoints.onlinePaymentMethods).path);
    expect(uri.queryParameters, {'amount': '100.00', 'currency': 'SAR'});
    expect(methods.single.gateway, 'myfatoorah_mada');
    expect(methods.single.totalAmount, 101.5);
  });

  test('creates an order payment using sdk channel', () async {
    final consumer = _FakeApiConsumer(
      postResponse: http.Response(
        '{"success":true,"data":{"reference":"PAY-1",'
        '"status":"pending","payment_url":"https://example.com/pay"}}',
        200,
      ),
    );
    final repository = RemoteOnlinePaymentsRepository(consumer);

    final payment = await repository.createOrderPayment(
      orderNumber: 'B2B-1',
      paymentMethodCode: 'md',
      channel: 'sdk',
    );

    expect(consumer.lastPostPath, '${EndPoints.onlinePayments}/orders/B2B-1');
    expect(consumer.lastPostBody, {'gateway': 'myfatoorah', 'channel': 'sdk'});
    expect(payment.reference, 'PAY-1');
    expect(payment.paymentUrl, 'https://example.com/pay');
  });

  test('keeps the backend payment error message for diagnostics', () async {
    final consumer = _FakeApiConsumer(
      postResponse: http.Response(
        '{"success":false,"error":{"message":"Order is not payable"}}',
        409,
      ),
    );
    final repository = RemoteOnlinePaymentsRepository(consumer);

    expect(
      () => repository.createOrderPayment(
        orderNumber: 'B2B-1',
        paymentMethodCode: 'md',
        channel: 'sdk',
      ),
      throwsA(
        isA<OnlinePaymentException>().having(
          (error) => error.messageKey,
          'messageKey',
          'Order is not payable (HTTP 409)',
        ),
      ),
    );
  });

  test('checks the final status through online-payments', () async {
    final consumer = _FakeApiConsumer(
      getResponse: http.Response(
        '{"success":true,"data":{"reference":"PAY-1",'
        '"status":"paid","payment_url":null,"amount":100,'
        '"currency":"SAR"}}',
        200,
      ),
    );
    final repository = RemoteOnlinePaymentsRepository(consumer);

    final payment = await repository.getPayment('PAY-1');

    expect(consumer.lastGetPath, '${EndPoints.onlinePayments}/PAY-1');
    expect(payment.isPaid, isTrue);
    expect(payment.amount, 100);
  });

  test('creates an SDK session from the backend payment reference', () async {
    final consumer = _FakeApiConsumer(
      postResponse: http.Response(
        '{"success":true,"data":{"session_id":"SESSION-1",'
        '"country_code":"SAU"}}',
        200,
      ),
    );
    final repository = RemoteOnlinePaymentsRepository(consumer);

    final session = await repository.createSession('PAY-1');

    expect(consumer.lastPostPath, '${EndPoints.onlinePayments}/PAY-1/session');
    expect(consumer.lastPostBody, isNull);
    expect(session.sessionId, 'SESSION-1');
    expect(session.countryCode, 'SAU');
  });

  test('executes the SDK session without sending an amount', () async {
    final consumer = _FakeApiConsumer(
      postResponse: http.Response(
        '{"success":true,"data":{"reference":"PAY-1",'
        '"status":"pending","payment_url":null}}',
        200,
      ),
    );
    final repository = RemoteOnlinePaymentsRepository(consumer);

    await repository.executePayment(reference: 'PAY-1', sessionId: 'SESSION-1');

    expect(consumer.lastPostPath, '${EndPoints.onlinePayments}/PAY-1/execute');
    expect(consumer.lastPostBody, {'session_id': 'SESSION-1'});
    expect(consumer.lastPostBody, isNot(contains('amount')));
  });
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer({this.getResponse, this.postResponse});

  final http.Response? getResponse;
  final http.Response? postResponse;
  String? lastGetPath;
  String? lastPostPath;
  Map<String, dynamic>? lastPostBody;

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    lastGetPath = path;
    return getResponse!;
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    lastPostPath = path;
    lastPostBody = body;
    return postResponse!;
  }

  @override
  Future<http.Response> delete(String path, Map<String, String>? headers) =>
      throw UnimplementedError();

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();

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
}
