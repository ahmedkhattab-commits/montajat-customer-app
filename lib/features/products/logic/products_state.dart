import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';

enum ProductsLayout { list, grid }

enum ProductsLoadStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.layout = ProductsLayout.grid,
    this.loadStatus = ProductsLoadStatus.initial,
    this.products = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.sort,
    this.errorMessageKey,
  });

  final ProductsLayout layout;
  final ProductsLoadStatus loadStatus;
  final List<ProductListingItem> products;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? sort;
  final String? errorMessageKey;

  ProductsState copyWith({
    ProductsLayout? layout,
    ProductsLoadStatus? loadStatus,
    List<ProductListingItem>? products,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? sort,
    bool clearSort = false,
    String? errorMessageKey,
    bool clearError = false,
  }) {
    return ProductsState(
      layout: layout ?? this.layout,
      loadStatus: loadStatus ?? this.loadStatus,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sort: clearSort ? null : sort ?? this.sort,
      errorMessageKey: clearError
          ? null
          : errorMessageKey ?? this.errorMessageKey,
    );
  }

  @override
  List<Object?> get props => [
    layout,
    loadStatus,
    products,
    currentPage,
    hasMore,
    isLoadingMore,
    sort,
    errorMessageKey,
  ];
}
