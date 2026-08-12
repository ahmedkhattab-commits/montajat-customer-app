import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';
import 'package:montajat_customer_app/features/categories/logic/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesState());

  final CategoriesRepository _repository;

  Future<void> loadCategories() => _fetchCategories(isRefresh: false);

  Future<void> refreshCategories() => _fetchCategories(isRefresh: true);

  Future<void> _fetchCategories({required bool isRefresh}) async {
    if (isClosed ||
        state.loadStatus == CategoriesLoadStatus.loading ||
        state.loadStatus == CategoriesLoadStatus.refreshing) {
      return;
    }

    emit(
      state.copyWith(
        loadStatus: isRefresh
            ? CategoriesLoadStatus.refreshing
            : CategoriesLoadStatus.loading,
        clearError: true,
      ),
    );
    try {
      final categories = await _repository.getCategories();
      if (isClosed) return;
      emit(
        state.copyWith(
          categories: categories,
          visibleCategories: _filter(categories, state.searchQuery, null),
          loadStatus: CategoriesLoadStatus.success,
          clearError: true,
        ),
      );
    } on CategoriesException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: CategoriesLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadStatus: CategoriesLoadStatus.failure,
          errorMessageKey: 'auth_errors.invalid_response',
        ),
      );
    }
  }

  void searchChanged(BuildContext context, String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        visibleCategories: _filter(state.categories, query, context),
      ),
    );
  }

  List<CategoryModel> _filter(
    List<CategoryModel> categories,
    String query,
    BuildContext? context,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return categories;

    return categories
        .where((category) {
          final localizedLabel = category.labelKey != null && context != null
              ? context.tr(category.labelKey!)
              : category.value;
          return localizedLabel.toLowerCase().contains(normalizedQuery) ||
              category.value.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }
}
