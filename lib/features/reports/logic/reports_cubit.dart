import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/reports/data/models/report_models.dart';
import 'package:montajat_customer_app/features/reports/data/repositories/reports_repository.dart';

enum ReportsStatus { initial, loading, success, failure }

class ReportsState {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.saved = const [],
    this.runs = const [],
    this.result,
    this.activeType,
    this.activeAction,
    this.errorKey,
  });

  final ReportsStatus status;
  final List<SavedReportModel> saved;
  final List<ReportRunModel> runs;
  final ReportResultModel? result;
  final String? activeType;
  final String? activeAction;
  final String? errorKey;

  ReportsState copyWith({
    ReportsStatus? status,
    List<SavedReportModel>? saved,
    List<ReportRunModel>? runs,
    ReportResultModel? result,
    String? activeType,
    String? activeAction,
    bool clearAction = false,
    String? errorKey,
    bool clearError = false,
  }) => ReportsState(
    status: status ?? this.status,
    saved: saved ?? this.saved,
    runs: runs ?? this.runs,
    result: result ?? this.result,
    activeType: activeType ?? this.activeType,
    activeAction: clearAction ? null : activeAction ?? this.activeAction,
    errorKey: clearError ? null : errorKey ?? this.errorKey,
  );
}

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._repository) : super(const ReportsState());
  final ReportsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ReportsStatus.loading, clearError: true));
    try {
      final values = await Future.wait<Object>([
        _repository.getSavedReports(),
        _repository.getRuns(),
      ]);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          saved: values[0] as List<SavedReportModel>,
          runs: values[1] as List<ReportRunModel>,
          clearError: true,
        ),
      );
    } on ReportsException catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ReportsStatus.failure,
            errorKey: error.messageKey,
          ),
        );
      }
    }
  }

  Future<bool> run(
    String type, {
    Map<String, String> filters = const {},
  }) async {
    emit(
      state.copyWith(activeAction: 'view', activeType: type, clearError: true),
    );
    try {
      final result = await _repository.runReport(type, filters: filters);
      if (isClosed) {
        return false;
      }
      emit(state.copyWith(result: result, clearAction: true, activeType: type));
      return true;
    } on ReportsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(clearAction: true, errorKey: error.messageKey));
      }
      return false;
    }
  }

  Future<bool> export(
    String type,
    String format, {
    Map<String, dynamic> filters = const {},
  }) async {
    emit(
      state.copyWith(activeAction: format, activeType: type, clearError: true),
    );
    try {
      await _repository.exportReport(type, format: format, filters: filters);
      final runs = await _repository.getRuns();
      if (isClosed) {
        return false;
      }
      emit(state.copyWith(runs: runs, clearAction: true, activeType: type));
      return true;
    } on ReportsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(clearAction: true, errorKey: error.messageKey));
      }
      return false;
    }
  }

  Future<void> deleteSaved(Object id) async {
    try {
      await _repository.deleteSavedReport(id);
      if (!isClosed) {
        emit(
          state.copyWith(
            saved: state.saved.where((item) => item.id != id).toList(),
            clearError: true,
          ),
        );
      }
    } on ReportsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorKey: error.messageKey));
      }
    }
  }

  Future<Uri> download(Object id) => _repository.getDownloadUrl(id);
}
