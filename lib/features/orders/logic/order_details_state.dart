import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';

enum OrderDetailsStatus { initial, loading, success, failure }

class OrderDetailsState extends Equatable {
  const OrderDetailsState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.cancelling = false,
    this.errorMessageKey,
  });

  final OrderDetailsStatus status;
  final OrderModel? order;
  final bool cancelling;
  final String? errorMessageKey;

  OrderDetailsState copyWith({
    OrderDetailsStatus? status,
    OrderModel? order,
    bool? cancelling,
    String? errorMessageKey,
    bool clearError = false,
  }) => OrderDetailsState(
    status: status ?? this.status,
    order: order ?? this.order,
    cancelling: cancelling ?? this.cancelling,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [status, order, cancelling, errorMessageKey];
}
