import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';

abstract interface class ProductsRepository {
  Future<ProductsPageModel> getProducts({
    required ProductsScreenArguments filter,
    required int page,
    int perPage = 20,
    String? query,
    String? sort,
  });
}

class RemoteProductsRepository implements ProductsRepository {
  const RemoteProductsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<ProductsPageModel> getProducts({
    required ProductsScreenArguments filter,
    required int page,
    int perPage = 20,
    String? query,
    String? sort,
  }) async {
    try {
      final parameters = <String, String>{
        'page': '$page',
        'per_page': '$perPage',
        if (query?.trim().isNotEmpty == true) 'q': query!.trim(),
      };
      if (filter.filterValue.trim().isNotEmpty) {
        switch (filter.source) {
          case ProductsFilterSource.all:
            break;
          case ProductsFilterSource.category:
            parameters['category'] = filter.filterValue;
            break;
          case ProductsFilterSource.brand:
            parameters['brand_code'] = filter.filterValue;
            break;
        }
      }
      if (sort != null) parameters['sort'] = sort;
      final uri = Uri.parse(
        EndPoints.catalogProducts,
      ).replace(queryParameters: parameters);
      final response = await _apiConsumer
          .get(uri.toString(), null)
          .timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw ProductsException(_errorKey(response.statusCode));
      }
      return ProductsPageModel.fromJson(json);
    } on TimeoutException {
      throw const ProductsException('auth_errors.timeout');
    } on http.ClientException {
      throw const ProductsException('auth_errors.network');
    } on FormatException {
      throw const ProductsException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid products response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class ProductsException implements Exception {
  const ProductsException(this.messageKey);

  final String messageKey;
}
