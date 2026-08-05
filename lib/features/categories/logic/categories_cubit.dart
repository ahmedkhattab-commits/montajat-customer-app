import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';
import 'package:montajat_customer_app/features/categories/logic/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit()
    : super(
        const CategoriesState(visibleCategories: CategoriesRepository.items),
      );

  void searchChanged(BuildContext context, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final visibleCategories = normalizedQuery.isEmpty
        ? CategoriesRepository.items
        : CategoriesRepository.items
              .where(
                (category) => context
                    .tr(category.labelKey)
                    .toLowerCase()
                    .contains(normalizedQuery),
              )
              .toList(growable: false);

    emit(
      state.copyWith(searchQuery: query, visibleCategories: visibleCategories),
    );
  }
}
