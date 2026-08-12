import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_model.dart';

abstract interface class ProductDetailsRepository {
  Future<ProductDetailsModel> getProductDetails(String itemCode);
}

class RemoteProductDetailsRepository implements ProductDetailsRepository {
  const RemoteProductDetailsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<ProductDetailsModel> getProductDetails(String itemCode) async {
    try {
      final response = await _apiConsumer
          .get(EndPoints.productDetails(itemCode), null)
          .timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw ProductDetailsException(_errorKey(response.statusCode));
      }
      final data = json['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid product details data');
      }
      return ProductDetailsModel.fromJson(data);
    } on TimeoutException {
      throw const ProductDetailsException('auth_errors.timeout');
    } on http.ClientException {
      throw const ProductDetailsException('auth_errors.network');
    } on FormatException {
      throw const ProductDetailsException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid product details response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    404 => 'product_details.not_found',
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class ProductDetailsException implements Exception {
  const ProductDetailsException(this.messageKey);

  final String messageKey;
}
