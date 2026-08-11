import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

enum HomeLoadStatus { initial, loading, refreshing, success, failure }

class HomeState {
  const HomeState({
    this.searchQuery = '',
    this.selectedCategory = 0,
    this.selectedNavigationIndex = 0,
    this.loadStatus = HomeLoadStatus.initial,
    this.sectionCount = 0,
    this.home,
    this.errorMessageKey,
  });

  final String searchQuery;
  final int selectedCategory;
  final int selectedNavigationIndex;
  final HomeLoadStatus loadStatus;
  final int sectionCount;
  final HomeResponseModel? home;
  final String? errorMessageKey;

  HomeState copyWith({
    String? searchQuery,
    int? selectedCategory,
    int? selectedNavigationIndex,
    HomeLoadStatus? loadStatus,
    int? sectionCount,
    HomeResponseModel? home,
    String? errorMessageKey,
    bool clearError = false,
  }) => HomeState(
    searchQuery: searchQuery ?? this.searchQuery,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    selectedNavigationIndex:
        selectedNavigationIndex ?? this.selectedNavigationIndex,
    loadStatus: loadStatus ?? this.loadStatus,
    sectionCount: sectionCount ?? this.sectionCount,
    home: home ?? this.home,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );
}
