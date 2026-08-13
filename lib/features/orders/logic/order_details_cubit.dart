import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/orders/data/repositories/orders_repository.dart';
import 'package:montajat_customer_app/features/orders/logic/order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository, this.orderNumber)
    : super(const OrderDetailsState());

  final OrdersRepository _repository;
  final String orderNumber;

  Future<void> loadOrder() async {
    emit(state.copyWith(status: OrderDetailsStatus.loading, clearError: true));
    try {
      final order = await _repository.getOrder(orderNumber);
      if (isClosed) return;
      emit(state.copyWith(status: OrderDetailsStatus.success, order: order));
    } on OrdersException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderDetailsStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on FormatException {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrderDetailsStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  Future<bool> cancelOrder() async {
    if (state.cancelling) return false;
    emit(state.copyWith(cancelling: true, clearError: true));
    try {
      final order = await _repository.cancelOrder(orderNumber);
      if (isClosed) return false;
      emit(
        state.copyWith(
          status: OrderDetailsStatus.success,
          order: order,
          cancelling: false,
        ),
      );
      return true;
    } on OrdersException catch (error) {
      if (isClosed) return false;
      emit(
        state.copyWith(cancelling: false, errorMessageKey: error.messageKey),
      );
      return false;
    }
  }
}
