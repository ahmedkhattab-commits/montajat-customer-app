import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

enum OffersLoadStatus { initial, loading, success, failure }

class OffersState extends Equatable {
  const OffersState({
    this.items = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadStatus = OffersLoadStatus.initial,
    this.errorMessageKey,
  });

  final List<HomeExpiryOfferModel> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final OffersLoadStatus loadStatus;
  final String? errorMessageKey;

  OffersState copyWith({
    List<HomeExpiryOfferModel>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    OffersLoadStatus? loadStatus,
    String? errorMessageKey,
    bool clearError = false,
  }) => OffersState(
    items: items ?? this.items,
    currentPage: currentPage ?? this.currentPage,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadStatus: loadStatus ?? this.loadStatus,
    errorMessageKey: clearError
        ? null
        : errorMessageKey ?? this.errorMessageKey,
  );

  @override
  List<Object?> get props => [
    items,
    currentPage,
    hasMore,
    isLoadingMore,
    loadStatus,
    errorMessageKey,
  ];
}
