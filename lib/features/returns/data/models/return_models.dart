class ReturnRequestModel {
  const ReturnRequestModel({
    required this.reference,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.lines,
    this.reason,
    this.notes,
  });

  final String reference;
  final String orderNumber;
  final String status;
  final DateTime? createdAt;
  final List<ReturnLineModel> lines;
  final String? reason;
  final String? notes;

  factory ReturnRequestModel.fromJson(Map<String, dynamic> json) {
    final items = json['lines'] ?? json['items'];
    return ReturnRequestModel(
      reference:
          _text(json['reference'] ?? json['return_reference'] ?? json['id']) ??
          '-',
      orderNumber: _text(json['order_number'] ?? json['order_no']) ?? '-',
      status: _text(json['status_label'] ?? json['status']) ?? '-',
      createdAt: DateTime.tryParse(
        _text(json['created_at'] ?? json['date']) ?? '',
      ),
      lines: items is List
          ? items
                .whereType<Map>()
                .map((e) => ReturnLineModel.fromJson(e.cast()))
                .toList()
          : const [],
      reason: _text(json['reason_name'] ?? json['reason']),
      notes: _text(json['notes']),
    );
  }
}

class ReturnReasonModel {
  const ReturnReasonModel({required this.id, required this.name});
  final Object id;
  final String name;
  factory ReturnReasonModel.fromJson(Map<String, dynamic> json) =>
      ReturnReasonModel(
        id: json['id'] ?? json['code'] ?? '',
        name: _text(json['name_ar'] ?? json['name'] ?? json['label']) ?? '-',
      );
}

class EligibleOrderModel {
  const EligibleOrderModel({required this.orderNumber, this.date});
  final String orderNumber;
  final DateTime? date;
  factory EligibleOrderModel.fromJson(Map<String, dynamic> json) =>
      EligibleOrderModel(
        orderNumber:
            _text(json['order_number'] ?? json['doc_num'] ?? json['number']) ??
            '-',
        date: DateTime.tryParse(
          _text(json['created_at'] ?? json['order_date'] ?? json['date']) ?? '',
        ),
      );
}

class ReturnLineModel {
  const ReturnLineModel({
    required this.itemCode,
    required this.name,
    required this.maxQuantity,
    this.quantity = 0,
  });
  final String itemCode;
  final String name;
  final int maxQuantity;
  final int quantity;
  ReturnLineModel copyWith({int? quantity}) => ReturnLineModel(
    itemCode: itemCode,
    name: name,
    maxQuantity: maxQuantity,
    quantity: quantity ?? this.quantity,
  );
  factory ReturnLineModel.fromJson(
    Map<String, dynamic> json,
  ) => ReturnLineModel(
    itemCode: _text(json['item_code'] ?? json['code']) ?? '-',
    name:
        _text(json['name'] ?? json['item_name'] ?? json['description']) ?? '-',
    maxQuantity: _integer(
      json['eligible_quantity'] ?? json['max_quantity'] ?? json['quantity'],
    ),
    quantity: _integer(json['return_quantity'] ?? json['requested_quantity']),
  );
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int _integer(Object? value) =>
    value is num ? value.round() : int.tryParse(value?.toString() ?? '') ?? 0;
