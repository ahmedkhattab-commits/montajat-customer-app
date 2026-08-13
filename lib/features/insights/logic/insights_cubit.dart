import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/insights/data/repositories/insights_repository.dart';
import 'package:montajat_customer_app/features/insights/logic/insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit(this._repository) : super(const InsightsState());

  final InsightsRepository _repository;

  Future<void> load({DateTime? from, DateTime? to}) async {
    if (state.status == InsightsLoadStatus.loading) return;
    final selectedFrom = from ?? state.selectedFrom;
    final selectedTo = to ?? state.selectedTo;
    emit(
      InsightsState(
        status: InsightsLoadStatus.loading,
        insights: state.insights,
        selectedFrom: selectedFrom,
        selectedTo: selectedTo,
      ),
    );
    try {
      final insights = await _repository.getInsights(
        from: selectedFrom,
        to: selectedTo,
      );
      if (isClosed) return;
      emit(
        InsightsState(
          status: InsightsLoadStatus.success,
          insights: insights,
          selectedFrom: insights.from,
          selectedTo: insights.to,
        ),
      );
    } on InsightsException catch (error) {
      if (isClosed) return;
      emit(
        InsightsState(
          status: InsightsLoadStatus.failure,
          insights: state.insights,
          selectedFrom: selectedFrom,
          selectedTo: selectedTo,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<void> selectPeriod(DateTime from, DateTime to) =>
      load(from: from, to: to);
}
