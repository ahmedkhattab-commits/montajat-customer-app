import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:montajat_customer_app/core/api/api_consumer.dart';
import 'package:montajat_customer_app/core/api/end_points.dart';
import 'package:montajat_customer_app/features/notifications/data/models/app_notification_model.dart';

abstract interface class NotificationsRepository {
  Future<List<AppNotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> readAll();
  Future<void> markAsRead(Object id);
  Future<void> delete(Object id);
}

class RemoteNotificationsRepository implements NotificationsRepository {
  const RemoteNotificationsRepository(this._api);
  final ApiConsumer _api;

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    final json = await _request(
      () => _api.get('${EndPoints.notifications}?per_page=100', null),
    );
    final data = json['data'];
    final items = data is List
        ? data
        : data is Map
        ? data['items'] ?? data['data']
        : null;
    if (items is! List) {
      throw const FormatException('notifications.data must be an array');
    }
    return items
        .whereType<Map>()
        .map((item) => AppNotificationModel.fromJson(item.cast()))
        .toList(growable: false);
  }

  @override
  Future<int> getUnreadCount() async {
    final data = (await _request(
      () => _api.get(EndPoints.notificationsUnreadCount, null),
    ))['data'];
    final value = data is Map ? data['unread_count'] : null;
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  @override
  Future<void> readAll() async =>
      _request(() => _api.post(EndPoints.notificationsReadAll, const {}, null));

  @override
  Future<void> markAsRead(Object id) async =>
      _request(() => _api.post(EndPoints.notificationRead(id), const {}, null));

  @override
  Future<void> delete(Object id) async =>
      _request(() => _api.delete(EndPoints.notification(id), null));

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(const Duration(seconds: 20));
      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{'success': true}
          : jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Invalid notifications response');
      }
      final json = decoded.cast<String, dynamic>();
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          json['success'] == false) {
        throw NotificationsException(_error(response.statusCode, json));
      }
      return json;
    } on TimeoutException {
      throw const NotificationsException('auth_errors.timeout');
    } on http.ClientException {
      throw const NotificationsException('auth_errors.network');
    } on FormatException {
      throw const NotificationsException('auth_errors.invalid_response');
    }
  }

  String _error(int status, Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map && error['message'] is String) return error['message'];
    return switch (status) {
      404 => 'notifications.not_found',
      >= 500 => 'auth_errors.server',
      _ => 'auth_errors.request_failed',
    };
  }
}

class NotificationsException implements Exception {
  const NotificationsException(this.messageKey);
  final String messageKey;
}
