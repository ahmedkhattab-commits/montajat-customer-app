import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/local_notification_service.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/firebase_options.dart';

abstract final class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      await _saveToken(await _messaging.getToken());
      _messaging.onTokenRefresh.listen(_saveToken);

      FirebaseMessaging.onMessage.listen((message) {
        if (Platform.isIOS) return;
        final notification = message.notification;
        if (notification == null) return;
        LocalNotificationService.show(
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: message.data.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        Future<void>.delayed(
          const Duration(milliseconds: 500),
          () => LocalNotificationService.handlePayload(initialMessage.data),
        );
      }
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => LocalNotificationService.handlePayload(message.data),
      );
    } on Object catch (error) {
      debugPrint('Firebase notifications unavailable: $error');
    }
  }

  static Future<String> getDeviceToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final token = await _messaging.getToken() ?? '';
      await _saveToken(token);
      return token;
    } on Object {
      return '';
    }
  }

  static Future<void> _saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await CacheHelper.setSecuredString(ConstantKeys.fcmToken, token);
  }
}
