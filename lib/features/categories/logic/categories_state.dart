import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';

enum CategoriesLoadStatus { initial, loading, refreshing, success, failure }

class CategoriesState {
  const CategoriesState({
    this.searchQuery = '',
    this.categories = const [],
    this.visibleCategories = const [],
    this.loadStatus = CategoriesLoadStatus.initial,
    this.errorMessageKey,
  });

  final String searchQuery;
  final List<CategoryModel> categories;
  final List<CategoryModel> visibleCategories;
  final CategoriesLoadStatus loadStatus;
  final String? errorMessageKey;

  CategoriesState copyWith({
    String? searchQuery,
    List<CategoryModel>? categories,
    List<CategoryModel>? visibleCategories,
    CategoriesLoadStatus? loadStatus,
    String? errorMessageKey,
    bool clearError = false,
  }) => CategoriesState(
    searchQuery: searchQuery ?? this.searchQuery,
    categories: categories ?? this.categories,
    visibleCategories: visibleCategories ?? this.visibleCategories,
    loadStatus: loadStatus ?? this.loadStatus,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );
}
