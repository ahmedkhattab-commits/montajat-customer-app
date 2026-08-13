import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/finance/data/models/finance_models.dart';

abstract interface class FinanceRepository {
  Future<FinanceSummaryModel> getSummary();
  Future<List<FinanceAgingBucket>> getAging();
  Future<List<FinanceDocumentModel>> getStatement({
    DateTime? from,
    DateTime? to,
  });
  Future<List<FinanceDocumentModel>> getPayments();
  Future<List<FinanceDocumentModel>> getCreditNotes();
  Future<List<FinanceDocumentModel>> getInvoices();
  Future<FinanceInvoiceDetailsModel> getInvoice(String docNum);
}

class RemoteFinanceRepository implements FinanceRepository {
  const RemoteFinanceRepository(this._api);
  final ApiConsumer _api;

  @override
  Future<FinanceSummaryModel> getSummary() async =>
      FinanceSummaryModel.fromJson(_data(await _get(EndPoints.financeSummary)));

  @override
  Future<List<FinanceAgingBucket>> getAging() async {
    final data = (await _get(EndPoints.financeAging))['data'];
    final list = data is List ? data : _dataList(_map(data)['buckets']);
    return list
        .whereType<Map>()
        .map((e) => FinanceAgingBucket.fromJson(e.cast()))
        .toList();
  }

  @override
  Future<List<FinanceDocumentModel>> getStatement({
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String>[];
    if (from != null) query.add('from=${_ymd(from)}');
    if (to != null) query.add('to=${_ymd(to)}');
    return _documents(
      await _get(
        '${EndPoints.financeStatement}${query.isEmpty ? '' : '?${query.join('&')}'}',
      ),
    );
  }

  @override
  Future<List<FinanceDocumentModel>> getPayments() async =>
      _documents(await _get(EndPoints.financePayments));

  @override
  Future<List<FinanceDocumentModel>> getCreditNotes() async =>
      _documents(await _get(EndPoints.financeCreditNotes));

  @override
  Future<List<FinanceDocumentModel>> getInvoices() async =>
      _documents(await _get(EndPoints.financeInvoices));

  @override
  Future<FinanceInvoiceDetailsModel> getInvoice(String docNum) async =>
      FinanceInvoiceDetailsModel.fromJson(
        _data(await _get(EndPoints.financeInvoiceDetails(docNum))),
      );

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await _api
          .get(path, null)
          .timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('finance response must be an object');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw FinanceException(
          response.statusCode == 404
              ? 'finance.not_found'
              : 'auth_errors.request_failed',
        );
      }
      return json;
    } on TimeoutException {
      throw const FinanceException('auth_errors.timeout');
    } on http.ClientException {
      throw const FinanceException('auth_errors.network');
    } on FormatException {
      throw const FinanceException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const FormatException('finance.data must be an object');
  }

  List<dynamic> _dataList(Object? data) => data is List ? data : const [];

  List<FinanceDocumentModel> _documents(Map<String, dynamic> json) {
    final data = json['data'];
    final list = data is List
        ? data
        : _dataList(_map(data)['items'] ?? _map(data)['data']);
    return list
        .whereType<Map>()
        .map((e) => FinanceDocumentModel.fromJson(e.cast()))
        .toList();
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map ? value.cast<String, dynamic>() : const {};
  String _ymd(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class FinanceException implements Exception {
  const FinanceException(this.messageKey);
  final String messageKey;
}
