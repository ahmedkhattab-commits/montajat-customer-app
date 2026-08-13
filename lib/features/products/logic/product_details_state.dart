import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_model.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';

enum ProductDetailsLoadStatus { initial, loading, success, failure }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.loadStatus = ProductDetailsLoadStatus.initial,
    this.details,
    this.quantity = 1,
    this.relatedProducts = const [],
    this.suggestedProducts = const [],
    this.errorMessageKey,
  });

  final ProductDetailsLoadStatus loadStatus;
  final ProductDetailsModel? details;
  final int quantity;
  final List<ProductListingItem> relatedProducts;
  final List<ProductListingItem> suggestedProducts;
  final String? errorMessageKey;

  ProductDetailsState copyWith({
    ProductDetailsLoadStatus? loadStatus,
    ProductDetailsModel? details,
    int? quantity,
    List<ProductListingItem>? relatedProducts,
    List<ProductListingItem>? suggestedProducts,
    String? errorMessageKey,
    bool clearError = false,
  }) => ProductDetailsState(
    loadStatus: loadStatus ?? this.loadStatus,
    details: details ?? this.details,
    quantity: quantity ?? this.quantity,
    relatedProducts: relatedProducts ?? this.relatedProducts,
    suggestedProducts: suggestedProducts ?? this.suggestedProducts,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    details,
    quantity,
    relatedProducts,
    suggestedProducts,
    errorMessageKey,
  ];
}
