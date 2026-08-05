import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class CacheHelper {
  static late SharedPreferences _sharedPreferences;
  static late FlutterSecureStorage _secureStorage;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _secureStorage = getIt<FlutterSecureStorage>();
  }

  static Future<bool?> setData(String key, Object value) async {
    debugPrint('SharedPrefHelper: setData with key: $key');
    if (value is String) return _sharedPreferences.setString(key, value);
    if (value is int) return _sharedPreferences.setInt(key, value);
    if (value is bool) return _sharedPreferences.setBool(key, value);
    if (value is double) return _sharedPreferences.setDouble(key, value);
    return null;
  }

  static Future<bool> getBool(String key) async {
    return _sharedPreferences.getBool(key) ?? true;
  }

  static bool? getNullableBool(String key) => _sharedPreferences.getBool(key);

  static double? getDouble(String key) => _sharedPreferences.getDouble(key);

  static Future<int?> getInt(String key) async {
    return _sharedPreferences.getInt(key);
  }

  static String? getString(String key) => _sharedPreferences.getString(key);

  static Future<void> removeData(String key) async {
    await _sharedPreferences.remove(key);
  }

  static Future<void> clearAllData() async {
    await _sharedPreferences.clear();
  }

  static Future<void> setSecuredString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String> getSecuredString(String key) async {
    return await _secureStorage.read(key: key) ?? '';
  }

  static Future<void> removeSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearAllSecuredData() async {
    await _secureStorage.deleteAll();
  }
}
