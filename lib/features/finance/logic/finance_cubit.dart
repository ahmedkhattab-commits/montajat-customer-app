import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/finance/data/models/finance_models.dart';
import 'package:montajat_customer_app/features/finance/data/repositories/finance_repository.dart';

enum FinanceStatus { initial, loading, success, partial, failure }

class FinanceState {
  const FinanceState({
    this.status = FinanceStatus.initial,
    this.summary,
    this.aging = const [],
    this.invoices = const [],
    this.payments = const [],
    this.creditNotes = const [],
    this.statement = const [],
    this.errorKey,
  });

  final FinanceStatus status;
  final FinanceSummaryModel? summary;
  final List<FinanceAgingBucket> aging;
  final List<FinanceDocumentModel> invoices;
  final List<FinanceDocumentModel> payments;
  final List<FinanceDocumentModel> creditNotes;
  final List<FinanceDocumentModel> statement;
  final String? errorKey;
}

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit(this._repository) : super(const FinanceState());
  final FinanceRepository _repository;

  Future<void> load() async {
    emit(const FinanceState(status: FinanceStatus.loading));
    final summary = await _safe(_repository.getSummary);
    final aging = await _safe(_repository.getAging);
    final invoices = await _safe(_repository.getInvoices);
    final payments = await _safe(_repository.getPayments);
    final creditNotes = await _safe(_repository.getCreditNotes);
    final statement = await _safe(_repository.getStatement);
    if (isClosed) return;
    if (summary == null) {
      emit(
        const FinanceState(
          status: FinanceStatus.failure,
          errorKey: 'auth_errors.request_failed',
        ),
      );
      return;
    }
    final isPartial = [
      aging,
      invoices,
      payments,
      creditNotes,
      statement,
    ].any((value) => value == null);
    emit(
      FinanceState(
        status: isPartial ? FinanceStatus.partial : FinanceStatus.success,
        summary: summary,
        aging: aging ?? const [],
        invoices: invoices ?? const [],
        payments: payments ?? const [],
        creditNotes: creditNotes ?? const [],
        statement: statement ?? const [],
        errorKey: isPartial ? 'finance.partial_data' : null,
      ),
    );
  }

  Future<T?> _safe<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Object {
      return null;
    }
  }
}

class InvoiceDetailsCubit extends Cubit<FinanceInvoiceDetailsModel?> {
  InvoiceDetailsCubit(this._repository, this.docNum) : super(null);
  final FinanceRepository _repository;
  final String docNum;
  String? errorKey;

  Future<void> load() async {
    try {
      final invoice = await _repository.getInvoice(docNum);
      if (!isClosed) emit(invoice);
    } on FinanceException catch (error) {
      errorKey = error.messageKey;
      if (!isClosed) emit(null);
    }
  }
}
