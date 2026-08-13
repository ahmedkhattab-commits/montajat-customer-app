import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

abstract interface class BrandsRepository {
  Future<List<HomeBrandModel>> getBrands();
}

class RemoteBrandsRepository implements BrandsRepository {
  const RemoteBrandsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<HomeBrandModel>> getBrands() async {
    try {
      final response = await _apiConsumer
          .get(EndPoints.brands, null)
          .timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw BrandsException(_errorKey(response.statusCode));
      }

      final data = json['data'];
      if (data is! List) {
        throw const FormatException('brands.data must be an array');
      }
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('brands.data[] must be an object');
            }
            return HomeBrandModel.fromJson(item);
          })
          .toList(growable: false);
    } on TimeoutException {
      throw const BrandsException('auth_errors.timeout');
    } on http.ClientException {
      throw const BrandsException('auth_errors.network');
    } on FormatException {
      throw const BrandsException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid brands response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class BrandsException implements Exception {
  const BrandsException(this.messageKey);

  final String messageKey;
}
