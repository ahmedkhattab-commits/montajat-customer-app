import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

enum BrandsLoadStatus { initial, loading, refreshing, success, failure }

class BrandsState {
  const BrandsState({
    this.brands = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadStatus = BrandsLoadStatus.initial,
    this.errorMessageKey,
  });

  final List<HomeBrandModel> brands;
  final bool hasMore;
  final bool isLoadingMore;
  final BrandsLoadStatus loadStatus;
  final String? errorMessageKey;

  BrandsState copyWith({
    List<HomeBrandModel>? brands,
    bool? hasMore,
    bool? isLoadingMore,
    BrandsLoadStatus? loadStatus,
    String? errorMessageKey,
    bool clearError = false,
  }) => BrandsState(
    brands: brands ?? this.brands,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadStatus: loadStatus ?? this.loadStatus,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );
}
