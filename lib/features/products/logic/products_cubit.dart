import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/data/repositories/products_repository.dart';
import 'package:montajat_customer_app/features/products/logic/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repository, this._filter) : super(const ProductsState());

  final ProductsRepository _repository;
  final ProductsScreenArguments _filter;

  Future<void> loadProducts() async {
    if (state.loadStatus == ProductsLoadStatus.loading) return;
    emit(
      state.copyWith(
        loadStatus: ProductsLoadStatus.loading,
        isLoadingMore: false,
        clearError: true,
      ),
    );
    try {
      final page = await _repository.getProducts(
        filter: _filter,
        page: 1,
        sort: state.sort,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ProductsLoadStatus.success,
          products: page.items,
          currentPage: page.currentPage,
          hasMore: page.hasMore,
          clearError: true,
        ),
      );
    } on ProductsException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ProductsLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<void> refreshProducts() => loadProducts();

  Future<void> loadMore() async {
    if (state.loadStatus != ProductsLoadStatus.success ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.getProducts(
        filter: _filter,
        page: state.currentPage + 1,
        sort: state.sort,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          products: [...state.products, ...page.items],
          currentPage: page.currentPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } on ProductsException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoadingMore: false, errorMessageKey: error.messageKey),
      );
    }
  }

  Future<void> sortByName() async {
    emit(state.copyWith(sort: 'name'));
    await loadProducts();
  }

  void changeLayout(ProductsLayout layout) {
    if (state.layout == layout) return;
    emit(state.copyWith(layout: layout));
  }
}
