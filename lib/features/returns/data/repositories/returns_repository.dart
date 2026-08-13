import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/returns/data/models/return_models.dart';

abstract interface class ReturnsRepository {
  Future<List<ReturnRequestModel>> getReturns();
  Future<ReturnRequestModel> getReturn(String reference);
  Future<List<ReturnReasonModel>> getReasons();
  Future<List<EligibleOrderModel>> getEligibleOrders();
  Future<List<ReturnLineModel>> getOrderLines(String orderNumber);
  Future<ReturnRequestModel> createReturn({
    required String orderNumber,
    required Object reasonId,
    required List<ReturnLineModel> lines,
    String? notes,
  });
}

class RemoteReturnsRepository implements ReturnsRepository {
  const RemoteReturnsRepository(this._api);
  final ApiConsumer _api;

  @override
  Future<List<ReturnRequestModel>> getReturns() async => _list(
    await _request(() => _api.get(EndPoints.returns, null)),
    ReturnRequestModel.fromJson,
  );

  @override
  Future<ReturnRequestModel> getReturn(String reference) async =>
      ReturnRequestModel.fromJson(
        _data(
          await _request(
            () => _api.get(EndPoints.returnDetails(reference), null),
          ),
        ),
      );

  @override
  Future<List<ReturnReasonModel>> getReasons() async => _list(
    await _request(() => _api.get(EndPoints.returnReasons, null)),
    ReturnReasonModel.fromJson,
  );

  @override
  Future<List<EligibleOrderModel>> getEligibleOrders() async => _list(
    await _request(() => _api.get(EndPoints.eligibleReturnOrders, null)),
    EligibleOrderModel.fromJson,
  );

  @override
  Future<List<ReturnLineModel>> getOrderLines(String orderNumber) async =>
      _list(
        await _request(
          () => _api.get(EndPoints.returnOrderLines(orderNumber), null),
        ),
        ReturnLineModel.fromJson,
      );

  @override
  Future<ReturnRequestModel> createReturn({
    required String orderNumber,
    required Object reasonId,
    required List<ReturnLineModel> lines,
    String? notes,
  }) async {
    final json = await _request(
      () => _api.post(EndPoints.returns, {
        'order_number': orderNumber,
        'reason_id': reasonId,
        'notes': notes,
        'lines': lines
            .where((e) => e.quantity > 0)
            .map((e) => {'item_code': e.itemCode, 'quantity': e.quantity})
            .toList(),
      }, null),
    );
    return ReturnRequestModel.fromJson(_data(json));
  }

  List<T> _list<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    final data = json['data'];
    final value = data is List
        ? data
        : data is Map
        ? (data['items'] ?? data['data'])
        : null;
    if (value is! List) return const [];
    return value.whereType<Map>().map((e) => parser(e.cast())).toList();
  }

  Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) return data.cast<String, dynamic>();
    throw const FormatException('returns.data must be an object');
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 25));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid returns response');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw ReturnsException(_error(response.statusCode, json));
      }
      return json;
    } on TimeoutException {
      throw const ReturnsException('auth_errors.timeout');
    } on http.ClientException {
      throw const ReturnsException('auth_errors.network');
    }
  }

  String _error(int status, Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map && error['message'] is String) return error['message'];
    if (json['message'] is String) return json['message'];
    return switch (status) {
      404 => 'returns.not_found',
      409 => 'returns.not_eligible',
      422 => 'returns.invalid_data',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }
}

class ReturnsException implements Exception {
  const ReturnsException(this.messageKey);
  final String messageKey;
}
