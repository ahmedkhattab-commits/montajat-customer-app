import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';

enum OrdersLoadStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersLoadStatus.initial,
    this.orders = const [],
    this.errorMessageKey,
  });

  final OrdersLoadStatus status;
  final List<OrderModel> orders;
  final String? errorMessageKey;

  OrdersState copyWith({
    OrdersLoadStatus? status,
    List<OrderModel>? orders,
    String? errorMessageKey,
    bool clearError = false,
  }) => OrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [status, orders, errorMessageKey];
}
