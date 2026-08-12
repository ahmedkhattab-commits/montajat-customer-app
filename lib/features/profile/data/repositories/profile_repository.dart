import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';

abstract interface class ProfileRepository {
  Future<ProfileModel> getProfile();
}

class RemoteProfileRepository implements ProfileRepository {
  const RemoteProfileRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final responses = await Future.wait([
        _apiConsumer.get(EndPoints.profile, null),
        _apiConsumer.get(EndPoints.profileCredit, null),
        _apiConsumer.get(EndPoints.profileAddresses, null),
      ]).timeout(const Duration(seconds: 20));
      final decoded = responses
          .map((response) {
            final json = _decode(response.body);
            if (response.statusCode < 200 ||
                response.statusCode >= 300 ||
                json['success'] != true) {
              throw ProfileException(_errorKey(response.statusCode));
            }
            return json;
          })
          .toList(growable: false);
      return ProfileModel.fromResponses(decoded[0], decoded[1], decoded[2]);
    } on TimeoutException {
      throw const ProfileException('auth_errors.timeout');
    } on http.ClientException {
      throw const ProfileException('auth_errors.network');
    } on FormatException {
      throw const ProfileException('auth_errors.invalid_response');
    }
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid profile response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class ProfileException implements Exception {
  const ProfileException(this.messageKey);

  final String messageKey;
}
