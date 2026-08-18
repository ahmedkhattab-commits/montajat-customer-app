import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/payments/data/models/online_payment_models.dart';

enum OrderPaymentStatus {
  initial,
  loading,
  ready,
  submitting,
  sdkReady,
  awaitingConfirmation,
  success,
  failure,
}

class OrderPaymentState extends Equatable {
  const OrderPaymentState({
    this.status = OrderPaymentStatus.initial,
    this.methods = const [],
    this.selectedGateway,
    this.payment,
    this.session,
    this.openPaymentPage = false,
    this.errorMessageKey,
  });

  final OrderPaymentStatus status;
  final List<OnlinePaymentMethodModel> methods;
  final String? selectedGateway;
  final OnlinePaymentModel? payment;
  final OnlinePaymentSessionModel? session;
  final bool openPaymentPage;
  final String? errorMessageKey;

  OrderPaymentState copyWith({
    OrderPaymentStatus? status,
    List<OnlinePaymentMethodModel>? methods,
    String? selectedGateway,
    OnlinePaymentModel? payment,
    OnlinePaymentSessionModel? session,
    bool? openPaymentPage,
    String? errorMessageKey,
    bool clearError = false,
  }) => OrderPaymentState(
    status: status ?? this.status,
    methods: methods ?? this.methods,
    selectedGateway: selectedGateway ?? this.selectedGateway,
    payment: payment ?? this.payment,
    session: session ?? this.session,
    openPaymentPage: openPaymentPage ?? this.openPaymentPage,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [
    status,
    methods,
    selectedGateway,
    payment,
    session,
    openPaymentPage,
    errorMessageKey,
  ];
}
