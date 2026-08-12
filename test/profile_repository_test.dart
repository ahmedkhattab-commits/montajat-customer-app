import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/profile/data/repositories/profile_repository.dart';

void main() {
  test('combines profile, credit, and addresses responses', () async {
    final consumer = _FakeApiConsumer({
      EndPoints.profile: http.Response(
        '{"success":true,"data":{"user":{"id":1,"name":"Ahmed",'
        '"mobile":"966500000000","email":null,"role":"owner",'
        '"permissions":{"can_place_orders":true,"can_view_financials":true}},'
        '"account":{"name":"Store","card_code":"555","city":"Riyadh",'
        '"country":"Saudi Arabia"}}}',
        200,
      ),
      EndPoints.profileCredit: http.Response(
        '{"success":true,"data":{"has_limit":false,"limit":null,'
        '"used":0,"available":null,"current_balance":25,'
        '"open_orders_balance":10,"currency":"SAR","is_exceeded":false}}',
        200,
      ),
      EndPoints.profileAddresses: http.Response(
        '{"success":true,"data":[{"id":1},{"id":2}]}',
        200,
      ),
    });

    final profile = await RemoteProfileRepository(consumer).getProfile();

    expect(profile.name, 'Ahmed');
    expect(profile.credit.currentBalance, 25);
    expect(profile.addressCount, 2);
    expect(
      consumer.paths,
      containsAll([
        EndPoints.profile,
        EndPoints.profileCredit,
        EndPoints.profileAddresses,
      ]),
    );
  });
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer(this.responses);
  final Map<String, http.Response> responses;
  final List<String> paths = [];

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    paths.add(path);
    return responses[path]!;
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
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
}
