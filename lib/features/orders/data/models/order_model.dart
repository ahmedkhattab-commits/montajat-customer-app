class OrderModel {
  const OrderModel({
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.statusLabelEn,
    required this.grandTotal,
    required this.currency,
    required this.createdAt,
    required this.subtotal,
    required this.vat,
    required this.isCancellable,
    required this.lines,
    this.requestedDeliveryDate,
    this.shipToCode,
    this.customerReference,
    this.notes,
  });

  final String orderNumber;
  final String status;
  final String statusLabel;
  final String statusLabelEn;
  final double grandTotal;
  final String currency;
  final DateTime? createdAt;
  final double subtotal;
  final double vat;
  final bool isCancellable;
  final List<OrderLineModel> lines;
  final DateTime? requestedDeliveryDate;
  final String? shipToCode;
  final String? customerReference;
  final String? notes;

  bool get isPaid => const {
    'paid',
    'completed',
    'delivered',
    'invoiced',
  }.contains(status.toLowerCase());

  String localizedStatus(String languageCode) =>
      languageCode == 'ar' || statusLabelEn.isEmpty
      ? statusLabel
      : statusLabelEn;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final totals = _map(json['totals']);
    final delivery = _map(json['delivery']);
    final rawLines = json['lines'];
    return OrderModel(
      orderNumber: _requiredString(json['order_number'], 'order_number'),
      status: _string(json['status']) ?? 'unknown',
      statusLabel:
          _string(json['status_label']) ?? _string(json['status']) ?? '-',
      statusLabelEn:
          _string(json['status_label_en']) ?? _string(json['status']) ?? '-',
      grandTotal: _number(json['grand_total'] ?? totals['grand_total']),
      currency:
          _string(json['currency'] ?? totals['currency'])?.toUpperCase() ??
          'SAR',
      createdAt: DateTime.tryParse(_string(json['created_at']) ?? ''),
      subtotal: _number(totals['subtotal']),
      vat: _number(totals['vat']),
      isCancellable: json['is_cancellable'] == true,
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map((line) => OrderLineModel.fromJson(line.cast()))
                .toList(growable: false)
          : const [],
      requestedDeliveryDate: DateTime.tryParse(
        _string(delivery['requested_date']) ?? '',
      ),
      shipToCode: _string(delivery['ship_to_code']),
      customerReference: _string(json['customer_reference']),
      notes: _string(json['notes']),
    );
  }
}

class OrderLineModel {
  const OrderLineModel({
    required this.itemCode,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String itemCode;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory OrderLineModel.fromJson(Map<String, dynamic> json) => OrderLineModel(
    itemCode: _requiredString(json['item_code'], 'item_code'),
    name: _string(json['name']) ?? _string(json['item_code']) ?? '-',
    quantity: _number(json['quantity']).round(),
    unitPrice: _number(json['unit_price']),
    lineTotal: _number(json['line_total']),
  );
}

Map<String, dynamic> _map(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : const {};

String _requiredString(Object? value, String field) {
  final result = _string(value);
  if (result == null) throw FormatException('$field must be a string');
  return result;
}

String? _string(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value is num) return value.toString();
  return null;
}

double _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
