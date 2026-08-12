import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';

abstract interface class CategoriesRepository {
  Future<List<CategoryModel>> getCategories();
}

class RemoteCategoriesRepository implements CategoriesRepository {
  const RemoteCategoriesRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiConsumer
          .get(EndPoints.categories, null)
          .timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw CategoriesException(_errorKey(response.statusCode));
      }

      final data = json['data'];
      if (data is! Map<String, dynamic> || data['category'] is! List) {
        throw const FormatException('Invalid categories response');
      }

      return (data['category'] as List)
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid category item');
            }
            return CategoryModel.fromJson(item);
          })
          .toList(growable: false);
    } on TimeoutException {
      throw const CategoriesException('auth_errors.timeout');
    } on http.ClientException {
      throw const CategoriesException('auth_errors.network');
    } on FormatException {
      throw const CategoriesException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid categories response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class CategoriesException implements Exception {
  const CategoriesException(this.messageKey);

  final String messageKey;
}
