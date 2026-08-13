import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/addresses/data/repositories/addresses_repository.dart';

void main() {
  test(
    'loads, updates, and prefers an address through documented endpoints',
    () async {
      final consumer = _FakeApiConsumer();
      final repository = RemoteAddressesRepository(consumer);

      final addresses = await repository.getAddresses();
      final cities = await repository.getCities();
      final updated = await repository.updateAddress(addresses.single);
      await repository.setPreferred(updated.id);

      expect(addresses.single.cityCode, 'RUH');
      expect(cities.single.name, 'Riyadh');
      expect(consumer.patchPath, EndPoints.addressDetails(7));
      expect(consumer.patchBody?['label'], 'Main branch');
      expect(consumer.postPath, EndPoints.preferredAddress(7));
    },
  );

  test('maps the live SAP address and string cities contract', () async {
    final repository = RemoteAddressesRepository(_LiveContractConsumer());

    final address = (await repository.getAddresses()).single;
    final city = (await repository.getCities()).single;

    expect(address.code, '555.B1');
    expect(address.district, 'حي العليا');
    expect(address.buildingNumber, '2140');
    expect(address.postalCode, '12211');
    expect(address.formatted, contains('طريق الملك عبدالعزيز'));
    expect(city.code, 'الرياض');
    expect(city.name, 'الرياض');
  });
}

class _LiveContractConsumer extends _FakeApiConsumer {
  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    if (path == EndPoints.addressCities) {
      return http.Response(
        '{"success":true,"data":["الرياض"]}',
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }
    return http.Response(
      '{"success":true,"data":[{"id":1,"code":"555.B1",'
      '"name":"555.B1","type_label":"عنوان التوصيل",'
      '"street":"طريق الملك عبدالعزيز","building":"2140",'
      '"city":"الرياض","county":"حي العليا",'
      '"state":"منطقة الرياض","country":"SA",'
      '"zip_code":"12211","formatted":'
      '"2140، طريق الملك عبدالعزيز، الرياض، منطقة الرياض، SA",'
      '"is_preferred":false}]}',
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

class _FakeApiConsumer implements ApiConsumer {
  String? patchPath;
  String? postPath;
  Map<String, dynamic>? patchBody;

  static const address =
      '{"id":7,"label":"Main branch","city":"Riyadh","city_code":"RUH",'
      '"district":"Olaya","street":"King Fahd Road","building_number":"27",'
      '"postal_code":"12211","contact_person":"Ahmed","phone":"0500000000",'
      '"notes":null,"is_preferred":false}';

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    if (path == EndPoints.addresses) {
      return http.Response('{"success":true,"data":[$address]}', 200);
    }
    if (path == EndPoints.addressCities) {
      return http.Response(
        '{"success":true,"data":[{"code":"RUH","name":"Riyadh"}]}',
        200,
      );
    }
    return http.Response('{"success":true,"data":$address}', 200);
  }

  @override
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    patchPath = path;
    patchBody = body;
    return http.Response('{"success":true,"data":$address}', 200);
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    postPath = path;
    return http.Response('{"success":true,"data":{}}', 200);
  }

  @override
  Future<http.Response> delete(String path, Map<String, String>? headers) =>
      throw UnimplementedError();
  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
}
