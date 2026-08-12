import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';

abstract interface class HomeRepository {
  Future<HomeResponseModel> getHome();
}

class RemoteHomeRepository implements HomeRepository {
  const RemoteHomeRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<HomeResponseModel> getHome() async {
    try {
      final responses = await Future.wait([
        _apiConsumer.get(EndPoints.home, null),
        _apiConsumer.get(EndPoints.expiryOffers, null),
      ]).timeout(const Duration(seconds: 20));
      final homeResponse = responses[0];
      final offersResponse = responses[1];
      final homeJson = _decode(homeResponse.body);
      final offersJson = _decode(offersResponse.body);

      if (!_isSuccessful(homeResponse, homeJson)) {
        throw HomeException(_errorKey(homeResponse.statusCode));
      }
      if (!_isSuccessful(offersResponse, offersJson)) {
        throw HomeException(_errorKey(offersResponse.statusCode));
      }

      if (kDebugMode) {
        final data = homeJson['data'];
        final sections = data is Map<String, dynamic> ? data['sections'] : null;
        final banners = sections is List
            ? sections
                  .where(
                    (section) =>
                        section is Map<String, dynamic> &&
                        section['type'] == 'banners',
                  )
                  .toList(growable: false)
            : const [];
        debugPrint('Banners response: ${jsonEncode(banners)}');
      }

      final home = HomeResponseModel.fromJson(homeJson);
      final offers = HomeResponseModel.expiryOffersFromJson(offersJson);
      return home.withExpiryOffers(offers);
    } on TimeoutException {
      throw const HomeException('auth_errors.timeout');
    } on http.ClientException {
      throw const HomeException('auth_errors.network');
    } on FormatException {
      throw const HomeException('auth_errors.invalid_response');
    }
  }

  bool _isSuccessful(http.Response response, Map<String, dynamic> json) =>
      response.statusCode >= 200 &&
      response.statusCode < 300 &&
      json['success'] == true;

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid home response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class HomeException implements Exception {
  const HomeException(this.messageKey);

  final String messageKey;
}
