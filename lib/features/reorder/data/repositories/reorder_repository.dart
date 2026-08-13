import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/reorder/data/models/reorder_product_model.dart';

abstract interface class ReorderRepository {
  Future<List<ReorderProductModel>> getMyProducts();
  Future<List<ReorderProductModel>> getDueProducts();
}

class RemoteReorderRepository implements ReorderRepository {
  const RemoteReorderRepository(this._api);
  final ApiConsumer _api;

  @override
  Future<List<ReorderProductModel>> getMyProducts() =>
      _load(EndPoints.reorderMyProducts);

  @override
  Future<List<ReorderProductModel>> getDueProducts() =>
      _load(EndPoints.reorderDue);

  Future<List<ReorderProductModel>> _load(String endpoint) async {
    try {
      final response = await _api
          .get(endpoint, null)
          .timeout(const Duration(seconds: 25));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid reorder response');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw ReorderException(_error(response.statusCode, json));
      }
      final data = json['data'];
      final values = data is List
          ? data
          : data is Map
          ? data['items'] ?? data['products'] ?? data['data']
          : null;
      if (values is! List) {
        throw const FormatException('reorder.data must be a list');
      }
      return values
          .whereType<Map>()
          .map((item) => ReorderProductModel.fromJson(item.cast()))
          .toList(growable: false);
    } on TimeoutException {
      throw const ReorderException('auth_errors.timeout');
    } on http.ClientException {
      throw const ReorderException('auth_errors.network');
    } on FormatException {
      throw const ReorderException('auth_errors.invalid_response');
    }
  }

  String _error(int status, Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map && error['message'] is String) {
      return error['message'];
    }
    if (json['message'] is String) return json['message'];
    return status >= 500 ? 'auth_errors.server' : 'auth_errors.request_failed';
  }
}

class ReorderException implements Exception {
  const ReorderException(this.messageKey);
  final String messageKey;
}
