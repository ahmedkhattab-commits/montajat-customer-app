class SavedReportModel {
  const SavedReportModel({
    required this.id,
    required this.name,
    required this.type,
    required this.filters,
  });

  final Object id;
  final String name;
  final String type;
  final Map<String, dynamic> filters;

  factory SavedReportModel.fromJson(Map<String, dynamic> json) =>
      SavedReportModel(
        id: json['id'] ?? '',
        name: _text(json['name'] ?? json['title']) ?? '-',
        type: _text(json['type'] ?? json['report_type']) ?? '-',
        filters: _map(json['filters'] ?? json['parameters']),
      );
}

class ReportRunModel {
  const ReportRunModel({
    required this.id,
    required this.type,
    required this.status,
    this.fileName,
    this.format,
    this.createdAt,
  });

  final Object id;
  final String type;
  final String status;
  final String? fileName;
  final String? format;
  final DateTime? createdAt;

  bool get canDownload =>
      const {'ready', 'completed', 'success'}.contains(status.toLowerCase());

  factory ReportRunModel.fromJson(Map<String, dynamic> json) => ReportRunModel(
    id: json['run_id'] ?? json['id'] ?? '',
    type: _text(json['type'] ?? json['report_type']) ?? '-',
    status: _text(json['status']) ?? '-',
    fileName: _text(json['file_name'] ?? json['name']),
    format: _text(json['format'] ?? json['file_type']),
    createdAt: DateTime.tryParse(_text(json['created_at']) ?? ''),
  );
}

class ReportResultModel {
  const ReportResultModel({required this.columns, required this.rows});
  final List<String> columns;
  final List<Map<String, dynamic>> rows;

  factory ReportResultModel.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'] ?? json['items'] ?? json['data'];
    final rows = rawRows is List
        ? rawRows
              .whereType<Map>()
              .map(
                (row) =>
                    row.map((key, value) => MapEntry(key.toString(), value)),
              )
              .toList()
        : <Map<String, dynamic>>[];
    final rawColumns = json['columns'];
    final columns = rawColumns is List
        ? rawColumns
              .map(
                (value) => value is Map
                    ? _text(value['key'] ?? value['name'])
                    : _text(value),
              )
              .whereType<String>()
              .toList()
        : rows.isEmpty
        ? <String>[]
        : rows.first.keys.toList();
    return ReportResultModel(columns: columns, rows: rows);
  }
}

Map<String, dynamic> _map(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : const {};

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
