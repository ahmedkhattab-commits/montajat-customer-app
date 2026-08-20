class ReorderProductModel {
  const ReorderProductModel({
    required this.itemCode,
    required this.name,
    required this.nameEn,
    required this.currency,
    required this.canOrder,
    this.imageUrl,
    this.price,
    this.lastQuantity,
    this.lastPurchasedAt,
    this.expectedReorderAt,
    this.daysUntilDue,
  });

  final String itemCode;
  final String name;
  final String? nameEn;
  final String? imageUrl;
  final num? price;
  final String currency;
  final int? lastQuantity;
  final DateTime? lastPurchasedAt;
  final DateTime? expectedReorderAt;
  final int? daysUntilDue;
  final bool canOrder;

  String localizedName(String languageCode) =>
      languageCode == 'en' && nameEn?.isNotEmpty == true ? nameEn! : name;

  bool get isOverdue => daysUntilDue != null
      ? daysUntilDue! <= 0
      : expectedReorderAt?.isBefore(DateTime.now()) == true;

  factory ReorderProductModel.fromJson(Map<String, dynamic> json) {
    final product = _map(json['product']);
    final price = _map(product['price'] ?? json['price']);
    final availability = _map(product['availability'] ?? json['availability']);
    return ReorderProductModel(
      itemCode: _requiredText(
        product['item_code'] ?? json['item_code'],
        'reorder.item_code',
      ),
      name: _text(product['name'] ?? json['name']) ?? '-',
      nameEn: _text(product['name_en'] ?? json['name_en']),
      imageUrl: _text(product['image_url'] ?? json['image_url']),
      price: _number(
        price['carton_price'] ??
            product['carton_price'] ??
            json['carton_price'],
      ),
      currency:
          _text(price['currency'] ?? json['currency'])?.toUpperCase() ?? 'SAR',
      lastQuantity: _integer(
        json['last_quantity'] ?? json['last_order_quantity'],
      ),
      lastPurchasedAt: _date(
        json['last_purchased_at'] ?? json['last_purchase_date'],
      ),
      expectedReorderAt: _date(
        json['expected_reorder_at'] ?? json['expected_reorder_date'],
      ),
      daysUntilDue: _integer(json['days_until_due'] ?? json['days_to_reorder']),
      canOrder:
          availability['can_order'] as bool? ??
          json['can_order'] as bool? ??
          true,
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? value.cast<String, dynamic>() : const {};
String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String _requiredText(Object? value, String field) =>
    _text(value) ?? (throw FormatException('$field is required'));
num? _number(Object? value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '');
int? _integer(Object? value) =>
    value is num ? value.round() : int.tryParse(value?.toString() ?? '');
DateTime? _date(Object? value) => DateTime.tryParse(_text(value) ?? '');
