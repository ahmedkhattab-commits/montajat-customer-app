import 'dart:convert';
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/app_interceptor.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;

class HttpConsumer implements ApiConsumer {
  http.Client _client;

  HttpConsumer(this._client) {
    _client = InterceptedClient.build(interceptors: [getIt<AppInterceptor>()]);
  }

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    final response = await _client.get(Uri.parse(path), headers: headers);
    return response;
  }

  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final response = await _client.put(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final response = await _client.patch(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final response = await _client.post(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> delete(
    String path,
    Map<String, String>? headers,
  ) async {
    final response = await _client.delete(Uri.parse(path), headers: headers);
    return response;
  }

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse(path));
    if (headers != null) {
      request.headers.addAll(headers);
    }
    body.forEach((key, value) async {
      if (key == "images") {
        for (var item in value as List<String>) {
          request.files.add(
            await http.MultipartFile.fromPath(key, item.toString()),
          );
        }
      } else if (key == "img") {
        request.files.add(
          await http.MultipartFile.fromPath(key, value.toString()),
        );
      } else if (key == "image") {
        request.files.add(
          await http.MultipartFile.fromPath(key, value.toString()),
        );
      } else if (key == "logo") {
        request.files.add(
          await http.MultipartFile.fromPath(key, value.toString()),
        );
      } else {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      }
    });
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
