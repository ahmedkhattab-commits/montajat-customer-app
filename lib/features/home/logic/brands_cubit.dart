import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/home/data/repositories/brands_repository.dart';
import 'package:montajat_customer_app/features/home/logic/brands_state.dart';

class BrandsCubit extends Cubit<BrandsState> {
  BrandsCubit(this._repository) : super(const BrandsState());

  static const pageSize = 18;
  final BrandsRepository _repository;

  Future<void> loadBrands() => _fetch(isRefresh: false);

  Future<void> refreshBrands() => _fetch(isRefresh: true);

  Future<void> _fetch({required bool isRefresh}) async {
    if (isClosed ||
        state.loadStatus == BrandsLoadStatus.loading ||
        state.loadStatus == BrandsLoadStatus.refreshing) {
      return;
    }
    emit(
      state.copyWith(
        loadStatus: isRefresh
            ? BrandsLoadStatus.refreshing
            : BrandsLoadStatus.loading,
        clearError: true,
      ),
    );
    try {
      final brands = await _repository.getBrands();
      if (isClosed) return;
      emit(
        state.copyWith(
          brands: brands,
          visibleCount: math.min(pageSize, brands.length),
          loadStatus: BrandsLoadStatus.success,
          clearError: true,
        ),
      );
    } on BrandsException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: BrandsLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: BrandsLoadStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  void loadNextPage() {
    if (isClosed || !state.hasMore) return;
    emit(
      state.copyWith(
        visibleCount: math.min(
          state.visibleCount + pageSize,
          state.brands.length,
        ),
      ),
    );
  }
}
