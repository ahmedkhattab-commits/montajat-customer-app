import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/products/data/repositories/product_details_repository.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/data/repositories/products_repository.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(
    this._repository,
    this._productsRepository,
    this._itemCode,
  ) : super(const ProductDetailsState());

  final ProductDetailsRepository _repository;
  final ProductsRepository _productsRepository;
  final String _itemCode;

  Future<void> loadDetails() async {
    if (state.loadStatus == ProductDetailsLoadStatus.loading) return;
    emit(
      state.copyWith(
        loadStatus: ProductDetailsLoadStatus.loading,
        clearError: true,
      ),
    );
    try {
      final details = await _repository.getProductDetails(_itemCode);
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ProductDetailsLoadStatus.success,
          details: details,
          clearError: true,
        ),
      );
      final recommendations = await Future.wait([
        _recommendations(ProductsFilterSource.category, details.category),
        _recommendations(ProductsFilterSource.brand, details.brandCode),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          relatedProducts: recommendations[0],
          suggestedProducts: recommendations[1],
        ),
      );
    } on ProductDetailsException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ProductDetailsLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<List<ProductListingItem>> _recommendations(
    ProductsFilterSource source,
    String? value,
  ) async {
    if (value == null || value.trim().isEmpty) return const [];
    try {
      final page = await _productsRepository.getProducts(
        filter: ProductsScreenArguments(
          source: source,
          filterValue: value,
          title: value,
        ),
        page: 1,
        perPage: 8,
      );
      return page.items
          .where((product) => product.itemCode != _itemCode)
          .take(6)
          .toList(growable: false);
    } on ProductsException {
      return const [];
    }
  }

  void incrementQuantity() => state.details?.product.isAvailable == true
      ? emit(state.copyWith(quantity: state.quantity + 1))
      : null;

  void decrementQuantity() {
    if (state.quantity > 1) emit(state.copyWith(quantity: state.quantity - 1));
  }
}
