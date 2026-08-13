class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.data,
  });

  final Object id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool isRead;
  final Map<String, dynamic> data;

  AppNotificationModel copyWith({bool? isRead}) => AppNotificationModel(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    data: data,
  );

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? rawData.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
    return AppNotificationModel(
      id: json['id'] ?? json['notification_id'] ?? '',
      title: _text(json['title'] ?? data['title']) ?? '-',
      body: _text(json['body'] ?? json['message'] ?? data['body']) ?? '',
      createdAt: DateTime.tryParse(
        _text(json['created_at'] ?? data['created_at']) ?? '',
      ),
      isRead:
          json['is_read'] == true ||
          json['read'] == true ||
          json['read_at'] != null,
      data: data,
    );
  }
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
