import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/products/data/repositories/product_details_repository.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository, this._itemCode)
    : super(const ProductDetailsState());

  final ProductDetailsRepository _repository;
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

  void incrementQuantity() => state.details?.product.isAvailable == true
      ? emit(state.copyWith(quantity: state.quantity + 1))
      : null;

  void decrementQuantity() {
    if (state.quantity > 1) emit(state.copyWith(quantity: state.quantity - 1));
  }
}
