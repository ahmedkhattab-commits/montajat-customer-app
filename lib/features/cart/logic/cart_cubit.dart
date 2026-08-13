import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/cart/data/repositories/cart_repository.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_state.dart';
import 'package:montajat_customer_app/features/orders/data/repositories/orders_repository.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository, this._ordersRepository)
    : super(const CartState());
  final CartRepository _repository;
  final OrdersRepository _ordersRepository;

  Future<void> loadCart({bool force = false}) async {
    if (state.loadStatus == CartLoadStatus.loading && !force) return;
    emit(state.copyWith(loadStatus: CartLoadStatus.loading, clearError: true));
    try {
      final cart = await _repository.getCart();
      if (isClosed) return;
      emit(state.copyWith(loadStatus: CartLoadStatus.success, cart: cart));
    } on CartException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: CartLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on FormatException {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: CartLoadStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  Future<bool> addItem(String itemCode, {int quantity = 1}) async {
    if (state.mutatingItemCode != null || quantity < 1) return false;
    emit(state.copyWith(mutatingItemCode: itemCode, clearError: true));
    try {
      await _repository.addItem(itemCode: itemCode, quantity: quantity);
      final cart = await _repository.getCart();
      if (isClosed) return false;
      emit(
        state.copyWith(
          cart: cart,
          clearMutatingItem: true,
          loadStatus: CartLoadStatus.success,
        ),
      );
      return true;
    } on CartException catch (error) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          clearMutatingItem: true,
          errorMessageKey: error.messageKey,
        ),
      );
      return false;
    } on FormatException {
      if (isClosed) return false;
      emit(
        state.copyWith(
          clearMutatingItem: true,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
      return false;
    }
  }

  Future<void> changeQuantity(String itemCode, int quantity) async {
    if (state.mutatingItemCode != null || quantity < 1) return;
    emit(state.copyWith(mutatingItemCode: itemCode, clearError: true));
    try {
      await _repository.updateItem(itemCode: itemCode, quantity: quantity);
      final cart = await _repository.getCart();
      if (isClosed) return;
      emit(
        state.copyWith(
          cart: cart,
          clearMutatingItem: true,
          loadStatus: CartLoadStatus.success,
        ),
      );
    } on CartException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearMutatingItem: true,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<void> removeItem(String itemCode) async {
    if (state.mutatingItemCode != null) return;
    emit(state.copyWith(mutatingItemCode: itemCode, clearError: true));
    try {
      await _repository.removeItem(itemCode);
      final cart = await _repository.getCart();
      if (isClosed) return;
      emit(
        state.copyWith(
          cart: cart,
          clearMutatingItem: true,
          loadStatus: CartLoadStatus.success,
        ),
      );
    } on CartException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          clearMutatingItem: true,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<void> clearCart() async {
    if (state.clearing) return;
    emit(state.copyWith(clearing: true, clearError: true));
    try {
      await _repository.clearCart();
      final cart = await _repository.getCart();
      if (isClosed) return;
      emit(state.copyWith(cart: cart, clearing: false));
    } on CartException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(clearing: false, errorMessageKey: error.messageKey));
    }
  }

  Future<bool> updateDelivery({
    required String shipToCode,
    required DateTime requestedDeliveryDate,
    String? deliveryNotes,
  }) async {
    if (state.savingDelivery) return false;
    emit(state.copyWith(savingDelivery: true, clearError: true));
    try {
      await _repository.updateDelivery(
        shipToCode: shipToCode,
        requestedDeliveryDate: requestedDeliveryDate,
        deliveryNotes: deliveryNotes,
      );
      final cart = await _repository.getCart();
      if (isClosed) return false;
      emit(state.copyWith(cart: cart, savingDelivery: false));
      return true;
    } on CartException catch (error) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          savingDelivery: false,
          errorMessageKey: error.messageKey,
        ),
      );
      return false;
    }
  }

  Future<void> checkout() async {
    if (state.checkingOut || state.cart?.isEmpty != false) return;
    emit(state.copyWith(checkingOut: true, clearError: true));
    try {
      final order = await _ordersRepository.checkout();
      if (isClosed) return;
      emit(
        state.copyWith(
          checkingOut: false,
          createdOrderNumber: order.orderNumber,
        ),
      );
    } on OrdersException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(checkingOut: false, errorMessageKey: error.messageKey),
      );
    }
  }
}
