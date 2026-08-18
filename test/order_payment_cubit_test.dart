import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';
import 'package:montajat_customer_app/features/payments/data/local/pending_payment_store.dart';
import 'package:montajat_customer_app/features/payments/data/models/online_payment_models.dart';
import 'package:montajat_customer_app/features/payments/data/repositories/online_payments_repository.dart';
import 'package:montajat_customer_app/features/payments/logic/order_payment_cubit.dart';

void main() {
  test('shows only the supported checkout payment methods', () async {
    final cubit = OrderPaymentCubit(
      _FakeRepository(),
      _order,
      _FakePendingPaymentStore(),
    );

    await cubit.loadMethods();

    expect(cubit.state.methods.map((method) => method.gateway), [
      'md',
      'stc',
      'gp',
      'ap',
    ]);
    expect(cubit.state.methods.first.nameAr, 'مدى');
    await cubit.close();
  });

  test('starts card payments using sdk channel', () async {
    final repository = _FakeRepository();
    final cubit = OrderPaymentCubit(
      repository,
      _order,
      _FakePendingPaymentStore(),
    );

    await cubit.loadMethods();
    await cubit.selectMethod('md');
    await cubit.pay();

    expect(repository.lastChannel, 'sdk');
    expect(cubit.state.session?.countryCode, 'SAU');
    await cubit.close();
  });

  test('starts STC Pay using hosted channel without a card session', () async {
    final repository = _FakeRepository();
    final cubit = OrderPaymentCubit(
      repository,
      _order,
      _FakePendingPaymentStore(),
    );

    await cubit.loadMethods();
    await cubit.selectMethod('stc');
    await cubit.pay();

    expect(repository.lastChannel, 'hosted');
    expect(cubit.state.session, isNull);
    expect(cubit.state.status.name, 'awaitingConfirmation');
    await cubit.close();
  });

  test('maps payment methods to their dynamic UI type', () {
    expect(_method('md').type, OnlinePaymentMethodType.card);
    expect(_method('stc').type, OnlinePaymentMethodType.stcPay);
    expect(_method('gp').type, OnlinePaymentMethodType.googlePay);
    expect(_method('ap').type, OnlinePaymentMethodType.applePay);
  });

  test('resumes a pending sdk payment by requesting a new session', () async {
    final repository = _FakeRepository();
    final pendingStore = _FakePendingPaymentStore(reference: 'TXN-OLD');
    final cubit = OrderPaymentCubit(repository, _order, pendingStore);

    await cubit.loadMethods();

    expect(repository.requestedSessionReference, 'TXN-OLD');
    expect(cubit.state.status.name, 'sdkReady');
    expect(cubit.state.methods.map((method) => method.gateway), [
      'md',
      'stc',
      'gp',
      'ap',
    ]);
    expect(cubit.state.selectedGateway, 'md');

    await cubit.selectMethod('stc');

    expect(cubit.state.selectedGateway, 'stc');
    expect(cubit.state.status.name, 'ready');
    expect(cubit.state.session, isNull);
    expect(pendingStore.removed, isTrue);
    await cubit.close();
  });

  test('switches from Mada to Google Pay using the same sdk session', () async {
    final cubit = OrderPaymentCubit(
      _FakeRepository(),
      _order,
      _FakePendingPaymentStore(reference: 'TXN-OLD'),
    );

    await cubit.loadMethods();
    final session = cubit.state.session;
    await cubit.selectMethod('gp');

    expect(cubit.state.selectedGateway, 'gp');
    expect(cubit.state.status.name, 'sdkReady');
    expect(cubit.state.session, same(session));
    await cubit.close();
  });
}

class _FakePendingPaymentStore implements PendingPaymentStore {
  _FakePendingPaymentStore({this.reference});

  final String? reference;
  bool removed = false;

  @override
  String? read(String orderNumber) => reference;

  @override
  Future<void> remove(String orderNumber) async => removed = true;

  @override
  Future<void> save(String orderNumber, String reference) async {}
}

const _order = OrderModel(
  orderNumber: 'B2B-1',
  status: 'approved',
  statusLabel: 'معتمد',
  statusLabelEn: 'Approved',
  grandTotal: 100,
  currency: 'SAR',
  createdAt: null,
  subtotal: 100,
  vat: 15,
  isCancellable: false,
  lines: [],
);

OnlinePaymentMethodModel _method(String gateway) =>
    OnlinePaymentMethodModel.fromJson({
      'gateway': gateway,
      'service_charge': 0,
      'total_amount': 100,
      'currency': 'SAR',
    });

class _FakeRepository implements OnlinePaymentsRepository {
  String? lastChannel;
  String? requestedSessionReference;

  @override
  Future<List<OnlinePaymentMethodModel>> getMethods({
    required num amount,
    required String currency,
  }) async => ['md', 'stc', 'uaecc', 'ae', 'gp', 'b', 'kn', 'ap', 'vm']
      .map(
        (gateway) => OnlinePaymentMethodModel.fromJson({
          'gateway': gateway,
          'service_charge': 0,
          'total_amount': amount,
          'currency': currency,
        }),
      )
      .toList(growable: false);

  @override
  Future<OnlinePaymentModel> createOrderPayment({
    required String orderNumber,
    required String paymentMethodCode,
    required String channel,
  }) async {
    lastChannel = channel;
    return OnlinePaymentModel(
      reference: 'TXN-1',
      status: 'pending',
      paymentUrl: channel == 'hosted' ? 'https://example.test/pay' : null,
      statusReason: null,
      amount: 100,
      currency: 'SAR',
    );
  }

  @override
  Future<OnlinePaymentSessionModel> createSession(String reference) async {
    requestedSessionReference = reference;
    return const OnlinePaymentSessionModel(
      sessionId: 'session-1',
      countryCode: 'SAU',
    );
  }

  @override
  Future<OnlinePaymentModel> executePayment({
    required String reference,
    required String sessionId,
  }) => throw UnimplementedError();

  @override
  Future<OnlinePaymentModel> getPayment(String reference) => Future.value(
    OnlinePaymentModel(
      reference: reference,
      status: 'pending',
      paymentUrl: null,
      statusReason: null,
      amount: 100,
      currency: 'SAR',
    ),
  );
}
