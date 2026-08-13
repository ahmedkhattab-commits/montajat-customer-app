import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/cart/data/models/cart_model.dart';

enum CartLoadStatus { initial, loading, success, failure }

class CartState extends Equatable {
  const CartState({
    this.loadStatus = CartLoadStatus.initial,
    this.cart,
    this.mutatingItemCode,
    this.clearing = false,
    this.savingDelivery = false,
    this.checkingOut = false,
    this.createdOrderNumber,
    this.errorMessageKey,
  });

  final CartLoadStatus loadStatus;
  final CartModel? cart;
  final String? mutatingItemCode;
  final bool clearing;
  final bool savingDelivery;
  final bool checkingOut;
  final String? createdOrderNumber;
  final String? errorMessageKey;

  CartState copyWith({
    CartLoadStatus? loadStatus,
    CartModel? cart,
    String? mutatingItemCode,
    bool clearMutatingItem = false,
    bool? clearing,
    bool? savingDelivery,
    bool? checkingOut,
    String? createdOrderNumber,
    String? errorMessageKey,
    bool clearError = false,
  }) => CartState(
    loadStatus: loadStatus ?? this.loadStatus,
    cart: cart ?? this.cart,
    mutatingItemCode: clearMutatingItem
        ? null
        : mutatingItemCode ?? this.mutatingItemCode,
    clearing: clearing ?? this.clearing,
    savingDelivery: savingDelivery ?? this.savingDelivery,
    checkingOut: checkingOut ?? this.checkingOut,
    createdOrderNumber: createdOrderNumber ?? this.createdOrderNumber,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    cart,
    mutatingItemCode,
    clearing,
    savingDelivery,
    checkingOut,
    createdOrderNumber,
    errorMessageKey,
  ];
}
