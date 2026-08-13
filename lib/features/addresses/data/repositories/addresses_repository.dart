import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/addresses/data/models/address_model.dart';

abstract interface class AddressesRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddress(int id);
  Future<List<CityModel>> getCities();
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> setPreferred(int id);
}

class RemoteAddressesRepository implements AddressesRepository {
  const RemoteAddressesRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<AddressModel>> getAddresses() async =>
      _parseList(await _get(EndPoints.addresses), AddressModel.fromJson);

  @override
  Future<AddressModel> getAddress(int id) async =>
      AddressModel.fromJson(_dataMap(await _get(EndPoints.addressDetails(id))));

  @override
  Future<List<CityModel>> getCities() async =>
      _parseValues(await _get(EndPoints.addressCities), CityModel.fromValue);

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    final response = await _request(
      () => _apiConsumer.patch(
        EndPoints.addressDetails(address.id),
        address.toPortalUpdate(),
        null,
      ),
    );
    return AddressModel.fromJson(_dataMap(response));
  }

  @override
  Future<void> setPreferred(int id) async {
    await _request(
      () => _apiConsumer.post(EndPoints.preferredAddress(id), const {}, null),
    );
  }

  Future<Map<String, dynamic>> _get(String path) =>
      _request(() => _apiConsumer.get(path, null));

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(const Duration(seconds: 20));
      final json = _decode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] != true) {
        throw AddressesException(_errorKey(response.statusCode));
      }
      return json;
    } on TimeoutException {
      throw const AddressesException('auth_errors.timeout');
    } on http.ClientException {
      throw const AddressesException('auth_errors.network');
    } on FormatException {
      throw const AddressesException('auth_errors.invalid_response');
    }
  }

  List<T> _parseList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    final data = json['data'];
    if (data is! List) throw const FormatException('data must be an array');
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Invalid list item');
          }
          return parser(item);
        })
        .toList(growable: false);
  }

  List<T> _parseValues<T>(
    Map<String, dynamic> json,
    T Function(Object?) parser,
  ) {
    final data = json['data'];
    if (data is! List) throw const FormatException('data must be an array');
    return data.map(parser).toList(growable: false);
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    throw const FormatException('data must be an object');
  }

  Map<String, dynamic> _decode(String body) {
    final value = jsonDecode(body);
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid addresses response');
  }

  String _errorKey(int statusCode) => switch (statusCode) {
    404 => 'addresses.not_found',
    422 => 'addresses.invalid_data',
    429 => 'auth_errors.too_many_requests',
    >= 500 => 'auth_errors.server',
    _ => 'auth_errors.request_failed',
  };
}

class AddressesException implements Exception {
  const AddressesException(this.messageKey);
  final String messageKey;
}
