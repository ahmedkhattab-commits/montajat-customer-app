import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/app_settings/data/models/app_settings_model.dart';

abstract interface class AppSettingsRepository {
  Future<AppSettingsModel> getSettings();
}

class RemoteAppSettingsRepository implements AppSettingsRepository {
  const RemoteAppSettingsRepository(this._api);

  final ApiConsumer _api;

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      final response = await _api
          .get(EndPoints.appSettings, null)
          .timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('app-settings response must be an object');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw const AppSettingsException();
      }
      final data = json['data'];
      if (data is! Map) {
        throw const FormatException('app-settings.data must be an object');
      }
      return AppSettingsModel.fromJson(data.cast<String, dynamic>());
    } on TimeoutException {
      throw const AppSettingsException();
    } on http.ClientException {
      throw const AppSettingsException();
    } on FormatException {
      throw const AppSettingsException();
    }
  }
}

class AppSettingsException implements Exception {
  const AppSettingsException();
}
