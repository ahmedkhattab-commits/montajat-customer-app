import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

class OffersPageModel {
  const OffersPageModel({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });

  final List<HomeExpiryOfferModel> items;
  final int currentPage;
  final bool hasMore;

  factory OffersPageModel.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! List) {
      throw const FormatException('Invalid offers response');
    }
    final meta = json['meta'];
    final pagination = meta is Map<String, dynamic> ? meta['pagination'] : null;
    if (pagination is! Map<String, dynamic>) {
      throw const FormatException('offers.meta.pagination must be an object');
    }
    return OffersPageModel(
      items: HomeResponseModel.expiryOffersFromJson(json),
      currentPage: _requiredInt(
        pagination['current_page'],
        'pagination.current_page',
      ),
      hasMore: _requiredBool(pagination['has_more'], 'pagination.has_more'),
    );
  }
}

abstract interface class OffersRepository {
  Future<OffersPageModel> getOffers({required int page, int perPage = 20});
}

class RemoteOffersRepository implements OffersRepository {
  const RemoteOffersRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<OffersPageModel> getOffers({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final uri = Uri.parse(
        EndPoints.expiryOffers,
      ).replace(queryParameters: {'page': '$page', 'per_page': '$perPage'});
      final response = await _apiConsumer
          .get(uri.toString(), null)
          .timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw OffersException(_errorKey(response.statusCode));
      }
      return OffersPageModel.fromJson(json);
    } on TimeoutException {
      throw const OffersException('auth_errors.timeout');
    } on http.ClientException {
      throw const OffersException('auth_errors.network');
    } on FormatException {
      throw const OffersException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid offers response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class OffersException implements Exception {
  const OffersException(this.messageKey);

  final String messageKey;
}

int _requiredInt(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer');
}

bool _requiredBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean');
}
