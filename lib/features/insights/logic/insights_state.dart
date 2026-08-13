import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/insights/data/models/insights_model.dart';

enum InsightsLoadStatus { initial, loading, success, failure }

class InsightsState extends Equatable {
  const InsightsState({
    this.status = InsightsLoadStatus.initial,
    this.insights,
    this.selectedFrom,
    this.selectedTo,
    this.errorMessageKey,
  });

  final InsightsLoadStatus status;
  final InsightsModel? insights;
  final DateTime? selectedFrom;
  final DateTime? selectedTo;
  final String? errorMessageKey;

  @override
  List<Object?> get props => [
    status,
    insights,
    selectedFrom,
    selectedTo,
    errorMessageKey,
  ];
}
