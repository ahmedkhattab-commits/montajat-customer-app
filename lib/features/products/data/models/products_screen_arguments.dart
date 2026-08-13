enum ProductsFilterSource { all, category, brand }

class ProductsScreenArguments {
  const ProductsScreenArguments({
    required this.source,
    required this.filterValue,
    required this.title,
    this.initialQuery,
  });

  final ProductsFilterSource source;
  final String filterValue;
  final String title;
  final String? initialQuery;
}
