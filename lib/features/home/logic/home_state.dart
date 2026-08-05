class HomeState {
  const HomeState({
    this.searchQuery = '',
    this.selectedCategory = 0,
    this.selectedNavigationIndex = 0,
  });

  final String searchQuery;
  final int selectedCategory;
  final int selectedNavigationIndex;

  HomeState copyWith({
    String? searchQuery,
    int? selectedCategory,
    int? selectedNavigationIndex,
  }) => HomeState(
    searchQuery: searchQuery ?? this.searchQuery,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    selectedNavigationIndex:
        selectedNavigationIndex ?? this.selectedNavigationIndex,
  );
}
