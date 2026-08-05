import 'package:http/http.dart' as http;

abstract class ApiConsumer {
  Future<http.Response> get(String path, Map<String, String>? headers);

  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  );
  Future<http.Response> delete(String path, Map<String, String>? headers);

  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  );
}
