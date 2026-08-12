import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_model.dart';

enum ProductDetailsLoadStatus { initial, loading, success, failure }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.loadStatus = ProductDetailsLoadStatus.initial,
    this.details,
    this.quantity = 1,
    this.errorMessageKey,
  });

  final ProductDetailsLoadStatus loadStatus;
  final ProductDetailsModel? details;
  final int quantity;
  final String? errorMessageKey;

  ProductDetailsState copyWith({
    ProductDetailsLoadStatus? loadStatus,
    ProductDetailsModel? details,
    int? quantity,
    String? errorMessageKey,
    bool clearError = false,
  }) => ProductDetailsState(
    loadStatus: loadStatus ?? this.loadStatus,
    details: details ?? this.details,
    quantity: quantity ?? this.quantity,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [loadStatus, details, quantity, errorMessageKey];
}
