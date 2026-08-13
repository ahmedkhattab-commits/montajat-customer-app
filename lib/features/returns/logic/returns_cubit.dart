import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/returns/data/models/return_models.dart';
import 'package:montajat_customer_app/features/returns/data/repositories/returns_repository.dart';

class ReturnsState {
  const ReturnsState({
    this.loading = false,
    this.submitting = false,
    this.items = const [],
    this.orders = const [],
    this.reasons = const [],
    this.lines = const [],
    this.selectedOrder,
    this.selectedReason,
    this.details,
    this.error,
  });
  final bool loading;
  final bool submitting;
  final List<ReturnRequestModel> items;
  final List<EligibleOrderModel> orders;
  final List<ReturnReasonModel> reasons;
  final List<ReturnLineModel> lines;
  final String? selectedOrder;
  final Object? selectedReason;
  final ReturnRequestModel? details;
  final String? error;

  ReturnsState copyWith({
    bool? loading,
    bool? submitting,
    List<ReturnRequestModel>? items,
    List<EligibleOrderModel>? orders,
    List<ReturnReasonModel>? reasons,
    List<ReturnLineModel>? lines,
    String? selectedOrder,
    Object? selectedReason,
    ReturnRequestModel? details,
    String? error,
    bool clearError = false,
  }) => ReturnsState(
    loading: loading ?? this.loading,
    submitting: submitting ?? this.submitting,
    items: items ?? this.items,
    orders: orders ?? this.orders,
    reasons: reasons ?? this.reasons,
    lines: lines ?? this.lines,
    selectedOrder: selectedOrder ?? this.selectedOrder,
    selectedReason: selectedReason ?? this.selectedReason,
    details: details ?? this.details,
    error: clearError ? null : error ?? this.error,
  );
}

class ReturnsCubit extends Cubit<ReturnsState> {
  ReturnsCubit(this._repository) : super(const ReturnsState());
  final ReturnsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final values = await Future.wait([
        _repository.getReturns(),
        _repository.getEligibleOrders(),
        _repository.getReasons(),
      ]);
      emit(
        state.copyWith(
          loading: false,
          items: values[0] as List<ReturnRequestModel>,
          orders: values[1] as List<EligibleOrderModel>,
          reasons: values[2] as List<ReturnReasonModel>,
        ),
      );
    } on ReturnsException catch (e) {
      emit(state.copyWith(loading: false, error: e.messageKey));
    }
  }

  Future<void> selectOrder(String orderNumber) async {
    emit(
      state.copyWith(
        loading: true,
        selectedOrder: orderNumber,
        lines: const [],
        clearError: true,
      ),
    );
    try {
      emit(
        state.copyWith(
          loading: false,
          lines: await _repository.getOrderLines(orderNumber),
        ),
      );
    } on ReturnsException catch (e) {
      emit(state.copyWith(loading: false, error: e.messageKey));
    }
  }

  void selectReason(Object id) => emit(state.copyWith(selectedReason: id));

  void changeQuantity(int index, int value) {
    final lines = [...state.lines];
    lines[index] = lines[index].copyWith(
      quantity: value.clamp(0, lines[index].maxQuantity),
    );
    emit(state.copyWith(lines: lines));
  }

  Future<ReturnRequestModel?> submit(String? notes) async {
    if (state.selectedOrder == null ||
        state.selectedReason == null ||
        !state.lines.any((e) => e.quantity > 0)) {
      emit(state.copyWith(error: 'returns.select_required'));
      return null;
    }
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final result = await _repository.createReturn(
        orderNumber: state.selectedOrder!,
        reasonId: state.selectedReason!,
        lines: state.lines,
        notes: notes,
      );
      emit(state.copyWith(submitting: false, items: [result, ...state.items]));
      return result;
    } on ReturnsException catch (e) {
      emit(state.copyWith(submitting: false, error: e.messageKey));
      return null;
    }
  }

  Future<void> loadDetails(String reference) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      emit(
        state.copyWith(
          loading: false,
          details: await _repository.getReturn(reference),
        ),
      );
    } on ReturnsException catch (e) {
      emit(state.copyWith(loading: false, error: e.messageKey));
    }
  }
}
