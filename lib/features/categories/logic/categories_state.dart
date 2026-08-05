import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';

class CategoriesState {
  const CategoriesState({
    this.searchQuery = '',
    this.visibleCategories = const [],
  });

  final String searchQuery;
  final List<CategoryModel> visibleCategories;

  CategoriesState copyWith({
    String? searchQuery,
    List<CategoryModel>? visibleCategories,
  }) => CategoriesState(
    searchQuery: searchQuery ?? this.searchQuery,
    visibleCategories: visibleCategories ?? this.visibleCategories,
  );
}
