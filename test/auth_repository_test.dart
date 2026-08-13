import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/features/login/data/models/auth_session_model.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await ServicesLocator.init();
    await CacheHelper.init();
  });

  test('requests OTP with the documented endpoint and mobile field', () async {
    final consumer = _FakeApiConsumer(
      response: http.Response('{"success":true,"data":{}}', 200),
    );
    final repository = RemoteAuthRepository(consumer);

    await repository.requestOtp('+966501234567');

    expect(consumer.lastPath, EndPoints.requestOtp);
    expect(consumer.lastBody, {'mobile': '+966501234567'});
  });

  test('maps Laravel validation errors to AuthException', () async {
    final consumer = _FakeApiConsumer(
      response: http.Response(
        '{"success":false,"error":{"code":"VALIDATION_FAILED",'
        '"message":"بيانات غير صحيحة","fields":{"mobile":["رقم الجوال مطلوب"]}}}',
        422,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    final repository = RemoteAuthRepository(consumer);

    expect(
      () => repository.requestOtp(''),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'رقم الجوال مطلوب',
        ),
      ),
    );
  });

  test('parses the access and refresh tokens from the verify envelope', () {
    final session = AuthSessionModel.fromJson({
      'success': true,
      'data': {
        'access_token': 'access-token',
        'refresh_token': 'refresh-token',
      },
    }, mobile: '+966501234567');

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.mobile, '+966501234567');
  });

  test('stores verified session token only in secure storage', () async {
    await CacheHelper.setSecuredString(ConstantKeys.fcmToken, 'device-token');
    final consumer = _FakeApiConsumer(
      response: http.Response(
        '{"success":true,"data":{"token":"secure-token",'
        '"token_type":"Bearer","user":{},"account":{}}}',
        200,
      ),
    );
    final repository = RemoteAuthRepository(consumer);

    await repository.verifyOtp(mobile: '+966501234567', code: '1234');

    expect(consumer.lastBody, {
      'mobile': '+966501234567',
      'code': '1234',
      'token': 'device-token',
    });
    expect(
      await CacheHelper.getSecuredString(ConstantKeys.accessToken),
      'secure-token',
    );
    expect(CacheHelper.getString(ConstantKeys.accessToken), isNull);
    expect(await repository.hasActiveSession(), isTrue);
  });

  test('calls logout endpoint and clears the local session', () async {
    await CacheHelper.setSecuredString(
      ConstantKeys.accessToken,
      'secure-token',
    );
    await CacheHelper.setSecuredString(ConstantKeys.fcmToken, 'device-token');
    await CacheHelper.setData(ConstantKeys.savePhoneToShared, '0500000000');
    final consumer = _FakeApiConsumer(
      response: http.Response('{"success":true,"data":{}}', 200),
    );

    await RemoteAuthRepository(consumer).logout();

    expect(consumer.lastPath, EndPoints.logout);
    expect(consumer.lastBody, {'token': 'device-token'});
    expect(
      await CacheHelper.getSecuredString(ConstantKeys.accessToken),
      isEmpty,
    );
    expect(CacheHelper.getString(ConstantKeys.savePhoneToShared), isNull);
    expect(
      await CacheHelper.getSecuredString(ConstantKeys.fcmToken),
      'device-token',
    );
  });
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer({required this.response});

  final http.Response response;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    lastPath = path;
    lastBody = body;
    return response;
  }

  @override
  Future<http.Response> delete(String path, Map<String, String>? headers) =>
      throw UnimplementedError();

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) =>
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
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) => throw UnimplementedError();
}
