import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/my_app.dart';

abstract final class LocalNotificationService {
  static const channelKey = 'montajat_notifications';

  static Future<void> init() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: channelKey,
        channelName: 'Montajat notifications',
        channelDescription: 'Order and account notifications',
        defaultColor: const Color(0xFF4B7DB9),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
      ),
    ]);
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceived(ReceivedAction action) async {
    final payload = action.payload;
    if (payload == null) return;
    _navigate(payload.map((key, value) => MapEntry(key, value ?? '')));
  }

  static Future<void> show({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) => AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      channelKey: channelKey,
      title: title,
      body: body,
      payload: payload,
      category: NotificationCategory.Message,
      notificationLayout: NotificationLayout.Default,
    ),
  );

  static void handlePayload(Map<String, dynamic> data) =>
      _navigate(data.map((key, value) => MapEntry(key, value.toString())));

  static void _navigate(Map<String, String> payload) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    switch (payload['type'] ?? payload['click_action']) {
      case 'order':
      case 'order_details':
        final orderNumber = payload['order_number'];
        if (orderNumber != null && orderNumber.isNotEmpty) {
          navigator.pushNamed(Routes.orderDetails, arguments: orderNumber);
        } else {
          navigator.pushNamed(Routes.orders);
        }
      case 'return':
      case 'return_details':
        final reference = payload['reference'];
        if (reference != null && reference.isNotEmpty) {
          navigator.pushNamed(Routes.returnDetails, arguments: reference);
        } else {
          navigator.pushNamed(Routes.returns);
        }
      default:
        navigator.pushNamed(Routes.home);
    }
  }
}
