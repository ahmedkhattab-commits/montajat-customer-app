class AppSettingsModel {
  const AppSettingsModel({
    required this.isOpen,
    required this.acceptsOrdersWhenClosed,
    required this.maintenanceActive,
    required this.forceUpdate,
    this.imageUrl,
    this.message,
    this.messageEn,
  });

  final bool isOpen;
  final bool acceptsOrdersWhenClosed;
  final bool maintenanceActive;
  final bool forceUpdate;
  final String? imageUrl;
  final String? message;
  final String? messageEn;

  bool get blocksApp =>
      maintenanceActive || forceUpdate || (!isOpen && !acceptsOrdersWhenClosed);

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    final maintenance = _map(json['maintenance']);
    final version = _map(json['version']);
    return AppSettingsModel(
      isOpen: _bool(json['is_open'], fallback: true),
      acceptsOrdersWhenClosed: _bool(json['accepts_orders_when_closed']),
      maintenanceActive: _bool(maintenance['active']),
      forceUpdate: _bool(version['force_update']),
      imageUrl: _text(
        maintenance['image_url'] ??
            maintenance['image'] ??
            json['image_url'] ??
            json['closed_image_url'] ??
            json['image'],
      ),
      message: _text(
        maintenance['message'] ?? json['closed_message'] ?? json['message'],
      ),
      messageEn: _text(
        maintenance['message_en'] ??
            json['closed_message_en'] ??
            json['message_en'],
      ),
    );
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? value.cast<String, dynamic>() : const {};

  static bool _bool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return fallback;
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
