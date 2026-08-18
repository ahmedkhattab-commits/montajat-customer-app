import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';
import 'package:montajat_customer_app/features/payments/data/local/pending_payment_store.dart';
import 'package:montajat_customer_app/features/payments/data/models/online_payment_models.dart';
import 'package:montajat_customer_app/features/payments/data/repositories/online_payments_repository.dart';
import 'package:montajat_customer_app/features/payments/logic/order_payment_state.dart';

class OrderPaymentCubit extends Cubit<OrderPaymentState> {
  OrderPaymentCubit(
    this._repository,
    this.order, [
    PendingPaymentStore? pendingPaymentStore,
  ]) : _pendingPaymentStore =
           pendingPaymentStore ?? const CachePendingPaymentStore(),
       super(const OrderPaymentState());

  final OnlinePaymentsRepository _repository;
  final OrderModel order;
  final PendingPaymentStore _pendingPaymentStore;

  static const _visibleGateways = {'md', 'stc', 'gp', 'ap'};

  Future<void> loadMethods() async {
    if (state.status == OrderPaymentStatus.loading) return;
    emit(state.copyWith(status: OrderPaymentStatus.loading, clearError: true));
    try {
      final availableMethods = await _repository.getMethods(
        amount: order.grandTotal,
        currency: order.currency,
      );
      final methods = availableMethods
          .where(
            (method) => _visibleGateways.contains(method.gateway.toLowerCase()),
          )
          .toList(growable: false);
      if (await _restorePendingPayment(methods)) return;
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.ready,
          methods: methods,
          selectedGateway: methods.length == 1 ? methods.single.gateway : null,
          clearError: true,
        ),
      );
    } on OnlinePaymentException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on FormatException {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  Future<bool> _restorePendingPayment(
    List<OnlinePaymentMethodModel> methods,
  ) async {
    final reference = _pendingPaymentStore.read(order.orderNumber);
    if (reference == null || reference.isEmpty) return false;
    try {
      final payment = await _repository.getPayment(reference);
      if (payment.isPaid) {
        await _pendingPaymentStore.remove(order.orderNumber);
        if (!isClosed) {
          emit(
            state.copyWith(
              status: OrderPaymentStatus.success,
              payment: payment,
              clearError: true,
            ),
          );
        }
        return true;
      }
      if (payment.isTerminalFailure) {
        await _pendingPaymentStore.remove(order.orderNumber);
        return false;
      }
      if (payment.paymentUrl == null) {
        _log(
          'RESUME',
          'Resuming pending SDK payment; reference=${payment.reference}',
        );
        final session = await _repository.createSession(payment.reference);
        if (!isClosed) {
          emit(
            state.copyWith(
              status: OrderPaymentStatus.sdkReady,
              methods: methods,
              selectedGateway:
                  methods.any((method) => method.gateway.toLowerCase() == 'md')
                  ? methods
                        .firstWhere(
                          (method) => method.gateway.toLowerCase() == 'md',
                        )
                        .gateway
                  : null,
              payment: payment,
              session: session,
              clearError: true,
            ),
          );
        }
        return true;
      }
      if (!isClosed) {
        emit(
          state.copyWith(
            status: OrderPaymentStatus.awaitingConfirmation,
            methods: methods,
            payment: payment,
            errorMessageKey: 'payments.pending',
          ),
        );
      }
      return true;
    } on OnlinePaymentException catch (error) {
      if (error.code == 'PAYMENT_NOT_FOUND') {
        await _pendingPaymentStore.remove(order.orderNumber);
        return false;
      }
      rethrow;
    }
  }

  Future<void> selectMethod(String gateway) async {
    if (state.status == OrderPaymentStatus.ready) {
      emit(state.copyWith(selectedGateway: gateway, clearError: true));
      return;
    }
    if (state.status != OrderPaymentStatus.sdkReady ||
        state.selectedGateway == gateway) {
      return;
    }
    final method = state.methods.firstWhere((item) => item.gateway == gateway);
    if (method.type == OnlinePaymentMethodType.card ||
        method.type == OnlinePaymentMethodType.googlePay) {
      emit(state.copyWith(selectedGateway: gateway, clearError: true));
      return;
    }
    await _pendingPaymentStore.remove(order.orderNumber);
    if (isClosed) return;
    emit(
      OrderPaymentState(
        status: OrderPaymentStatus.ready,
        methods: state.methods,
        selectedGateway: gateway,
      ),
    );
  }

  Future<void> pay() async {
    final gateway = state.selectedGateway;
    if (gateway == null || state.status != OrderPaymentStatus.ready) return;
    emit(
      state.copyWith(status: OrderPaymentStatus.submitting, clearError: true),
    );
    try {
      final method = state.methods.firstWhere(
        (item) => item.gateway == gateway,
      );
      if (method.type == OnlinePaymentMethodType.card ||
          method.type == OnlinePaymentMethodType.googlePay) {
        _log('1/6', 'Starting SDK payment; gateway=$gateway');
        await _startSdkPayment(gateway);
      } else {
        _log('1/3', 'Starting hosted payment; gateway=$gateway');
        await _startHostedPayment(gateway);
      }
    } on OnlinePaymentException catch (error) {
      _log('ERROR', 'code=${error.code}; status=${error.statusCode}');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.ready,
          errorMessageKey: error.messageKey,
        ),
      );
    } on FormatException {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.ready,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  Future<void> _startHostedPayment(String gateway) async {
    final payment = await _repository.createOrderPayment(
      orderNumber: order.orderNumber,
      paymentMethodCode: gateway,
      channel: 'hosted',
    );
    await _pendingPaymentStore.save(order.orderNumber, payment.reference);
    if (payment.isPaid || payment.isTerminalFailure) {
      await _pendingPaymentStore.remove(order.orderNumber);
    }
    if (isClosed) return;
    if (!payment.isPaid &&
        !payment.isTerminalFailure &&
        payment.paymentUrl == null) {
      emit(
        state.copyWith(
          status: OrderPaymentStatus.ready,
          payment: payment,
          errorMessageKey: 'payments.hosted_url_missing',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: _statusFor(payment),
        payment: payment,
        openPaymentPage: payment.paymentUrl != null && !payment.isPaid,
        errorMessageKey: payment.isTerminalFailure
            ? _terminalMessageFor(payment)
            : null,
        clearError: !payment.isTerminalFailure,
      ),
    );
  }

  Future<void> _startSdkPayment(String gateway) async {
    _log('2/6', 'Creating transaction with channel=sdk');
    final payment = await _repository.createOrderPayment(
      orderNumber: order.orderNumber,
      paymentMethodCode: gateway,
      channel: 'sdk',
    );
    _log(
      '2/6',
      'Transaction created; reference=${payment.reference}; status=${payment.status}',
    );
    await _pendingPaymentStore.save(order.orderNumber, payment.reference);
    if (isClosed) return;
    if (payment.isPaid || payment.isTerminalFailure) {
      await _pendingPaymentStore.remove(order.orderNumber);
      emit(
        state.copyWith(
          status: _statusFor(payment),
          payment: payment,
          errorMessageKey: payment.isTerminalFailure
              ? _terminalMessageFor(payment)
              : null,
          clearError: !payment.isTerminalFailure,
        ),
      );
      return;
    }
    _log('3/6', 'Requesting SDK session; reference=${payment.reference}');
    final session = await _repository.createSession(payment.reference);
    _log(
      '3/6',
      'SDK session received; session_id=[REDACTED]; country=${session.countryCode}',
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        status: OrderPaymentStatus.sdkReady,
        payment: payment,
        session: session,
        clearError: true,
      ),
    );
  }

  Future<void> executeSdkPayment(String sessionId) async {
    final payment = state.payment;
    if (payment == null || state.status != OrderPaymentStatus.sdkReady) return;
    emit(
      state.copyWith(status: OrderPaymentStatus.submitting, clearError: true),
    );
    try {
      _log('5/6', 'Executing SDK payment; session_id=[REDACTED]');
      final executed = await _repository.executePayment(
        reference: payment.reference,
        sessionId: sessionId,
      );
      _log(
        '5/6',
        'Execute completed; status=${executed.status}; 3ds=${executed.paymentUrl != null}',
      );
      if (executed.isPaid || executed.isTerminalFailure) {
        await _pendingPaymentStore.remove(order.orderNumber);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: _statusFor(executed),
          payment: executed,
          openPaymentPage: executed.paymentUrl != null && !executed.isPaid,
          errorMessageKey: executed.isTerminalFailure
              ? _terminalMessageFor(executed)
              : null,
          clearError: !executed.isTerminalFailure,
        ),
      );
      if (executed.paymentUrl == null && !executed.isTerminalFailure) {
        await verifyPayment();
      }
    } on OnlinePaymentException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.sdkReady,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  void markPaymentPageOpened() {
    if (!state.openPaymentPage) return;
    emit(state.copyWith(openPaymentPage: false));
  }

  Future<void> verifyPayment() async {
    final reference = state.payment?.reference;
    if (reference == null ||
        state.status != OrderPaymentStatus.awaitingConfirmation) {
      return;
    }
    emit(
      state.copyWith(status: OrderPaymentStatus.submitting, clearError: true),
    );
    try {
      _log('6/6', 'Checking final status; reference=$reference');
      final payment = await _repository.getPayment(reference);
      _log('6/6', 'Final status=${payment.status}');
      if (payment.isPaid || payment.isTerminalFailure) {
        await _pendingPaymentStore.remove(order.orderNumber);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: _statusFor(payment),
          payment: payment,
          errorMessageKey: payment.isPaid
              ? null
              : payment.isTerminalFailure
              ? _terminalMessageFor(payment)
              : 'payments.pending',
        ),
      );
    } on OnlinePaymentException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderPaymentStatus.awaitingConfirmation,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  OrderPaymentStatus _statusFor(OnlinePaymentModel payment) {
    if (payment.isPaid) return OrderPaymentStatus.success;
    if (payment.isTerminalFailure) return OrderPaymentStatus.ready;
    return OrderPaymentStatus.awaitingConfirmation;
  }

  String _terminalMessageFor(OnlinePaymentModel payment) {
    final reason = payment.statusReason;
    if (reason != null && reason.isNotEmpty) {
      return reason;
    }
    return switch (payment.status.toLowerCase()) {
      'cancelled' => 'payments.cancelled',
      'expired' => 'payments.expired',
      _ => 'payments.failed',
    };
  }

  void _log(String step, String message) {
    if (kDebugMode) debugPrint('[Payment SDK][$step] $message');
  }
}
