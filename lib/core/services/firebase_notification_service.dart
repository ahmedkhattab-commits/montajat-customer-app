/// Firebase notifications are disabled until Firebase is configured for the
/// customer application.
abstract final class FirebaseNotificationService {
  static const bool isConfigured = false;

  static Future<void> init() async {}
}
