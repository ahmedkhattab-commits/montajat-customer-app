import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';
import 'package:montajat_customer_app/features/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository) : super(const HomeState());

  final HomeRepository _homeRepository;

  Future<void> loadHome() => _fetchHome(isRefresh: false);

  Future<void> refreshHome() => _fetchHome(isRefresh: true);

  Future<void> _fetchHome({required bool isRefresh}) async {
    if (isClosed ||
        state.loadStatus == HomeLoadStatus.loading ||
        state.loadStatus == HomeLoadStatus.refreshing) {
      return;
    }

    emit(
      state.copyWith(
        loadStatus: isRefresh
            ? HomeLoadStatus.refreshing
            : HomeLoadStatus.loading,
        clearError: true,
      ),
    );
    try {
      final response = await _homeRepository.getHome();
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: HomeLoadStatus.success,
          sectionCount: response.sectionCount,
          home: response,
          clearError: true,
        ),
      );
    } on HomeException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: HomeLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: HomeLoadStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  void categorySelected(int index) =>
      emit(state.copyWith(selectedCategory: index));

  void navigationSelected(int index) =>
      emit(state.copyWith(selectedNavigationIndex: index));
}
