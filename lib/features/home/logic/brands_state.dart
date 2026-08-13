import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

enum BrandsLoadStatus { initial, loading, refreshing, success, failure }

class BrandsState {
  const BrandsState({
    this.brands = const [],
    this.visibleCount = 0,
    this.loadStatus = BrandsLoadStatus.initial,
    this.errorMessageKey,
  });

  final List<HomeBrandModel> brands;
  final int visibleCount;
  final BrandsLoadStatus loadStatus;
  final String? errorMessageKey;

  List<HomeBrandModel> get visibleBrands =>
      brands.take(visibleCount).toList(growable: false);

  bool get hasMore => visibleCount < brands.length;

  BrandsState copyWith({
    List<HomeBrandModel>? brands,
    int? visibleCount,
    BrandsLoadStatus? loadStatus,
    String? errorMessageKey,
    bool clearError = false,
  }) => BrandsState(
    brands: brands ?? this.brands,
    visibleCount: visibleCount ?? this.visibleCount,
    loadStatus: loadStatus ?? this.loadStatus,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );
}
