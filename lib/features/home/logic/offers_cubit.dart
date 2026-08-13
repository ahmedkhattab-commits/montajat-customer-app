import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/home/data/repositories/offers_repository.dart';
import 'package:montajat_customer_app/features/home/logic/offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit(this._repository) : super(const OffersState());

  final OffersRepository _repository;

  Future<void> loadOffers() async {
    if (state.loadStatus == OffersLoadStatus.loading) return;
    emit(
      state.copyWith(
        loadStatus: OffersLoadStatus.loading,
        isLoadingMore: false,
        clearError: true,
      ),
    );
    try {
      final page = await _repository.getOffers(page: 1);
      if (isClosed) return;
      emit(
        state.copyWith(
          items: page.items,
          currentPage: page.currentPage,
          hasMore: page.hasMore,
          loadStatus: OffersLoadStatus.success,
          clearError: true,
        ),
      );
    } on OffersException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: OffersLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<void> refreshOffers() => loadOffers();

  Future<void> loadMore() async {
    if (state.loadStatus != OffersLoadStatus.success ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.getOffers(page: state.currentPage + 1);
      if (isClosed) return;
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          currentPage: page.currentPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } on OffersException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoadingMore: false, errorMessageKey: error.messageKey),
      );
    }
  }
}
