import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/orders/data/repositories/orders_repository.dart';
import 'package:montajat_customer_app/features/orders/logic/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersState());
  final OrdersRepository _repository;

  Future<void> loadOrders() async {
    emit(state.copyWith(status: OrdersLoadStatus.loading, clearError: true));
    try {
      final orders = await _repository.getOrders();
      if (isClosed) return;
      emit(state.copyWith(status: OrdersLoadStatus.success, orders: orders));
    } on OrdersException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrdersLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on FormatException {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrdersLoadStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }
}
