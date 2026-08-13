import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';

class HomeHeaderModel {
  const HomeHeaderModel({required this.storeName, required this.address});

  final String storeName;
  final String address;

  factory HomeHeaderModel.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response');
    }
    final data = json['data'] as Map<String, dynamic>;
    final account = data['account'];
    final addresses = data['addresses'];
    if (account is! Map<String, dynamic> || addresses is! List) {
      throw const FormatException('Invalid profile header data');
    }
    final storeName = account['name'];
    if (storeName is! String || storeName.trim().isEmpty) {
      throw const FormatException('profile.account.name must be a string');
    }

    Map<String, dynamic>? selectedAddress;
    for (final value in addresses) {
      if (value is Map<String, dynamic> && value['is_default'] == true) {
        selectedAddress = value;
        break;
      }
    }
    if (selectedAddress == null && addresses.isNotEmpty) {
      final first = addresses.first;
      if (first is Map<String, dynamic>) selectedAddress = first;
    }
    final formatted = selectedAddress?['formatted'];
    final address = formatted is String ? formatted.trim() : '';

    return HomeHeaderModel(storeName: storeName.trim(), address: address);
  }
}

abstract interface class HomeHeaderRepository {
  Future<HomeHeaderModel> getHeader();
}

class RemoteHomeHeaderRepository implements HomeHeaderRepository {
  const RemoteHomeHeaderRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<HomeHeaderModel> getHeader() async {
    try {
      final response = await _apiConsumer
          .get(EndPoints.profile, null)
          .timeout(const Duration(seconds: 20));
      final value = jsonDecode(response.body);
      if (value is! Map<String, dynamic> ||
          response.statusCode < 200 ||
          response.statusCode >= 300 ||
          value['success'] != true) {
        throw const HomeHeaderException();
      }
      return HomeHeaderModel.fromJson(value);
    } on TimeoutException {
      throw const HomeHeaderException();
    } on http.ClientException {
      throw const HomeHeaderException();
    } on FormatException {
      throw const HomeHeaderException();
    }
  }
}

class HomeHeaderException implements Exception {
  const HomeHeaderException();
}
