class CartModel {
  const CartModel({
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.vatAmount,
    required this.discountAmount,
    required this.total,
    required this.currency,
    required this.shipToCode,
    required this.requestedDeliveryDate,
    required this.deliveryNotes,
  });

  final List<CartItemModel> items;
  final int itemsCount;
  final num subtotal;
  final num vatAmount;
  final num discountAmount;
  final num total;
  final String currency;
  final String? shipToCode;
  final DateTime? requestedDeliveryDate;
  final String? deliveryNotes;

  bool get isEmpty => items.isEmpty;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data'], 'cart.data');
    final rawItems = data['lines'];
    if (rawItems is! List) {
      throw const FormatException('cart.data.lines must be an array');
    }
    final items = rawItems
        .map((value) => CartItemModel.fromJson(_map(value, 'cart.item')))
        .toList(growable: false);
    final summary = _map(data['totals'], 'cart.data.totals');
    final delivery = _map(data['meta'], 'cart.data.meta');
    return CartModel(
      items: items,
      itemsCount:
          _optionalInt(summary['item_count']) ??
          items.fold(0, (total, item) => total + item.quantity),
      subtotal:
          _optionalNum(summary['subtotal']) ??
          items.fold<num>(0, (total, item) => total + item.lineTotal),
      vatAmount: _optionalNum(summary['vat']) ?? 0,
      discountAmount: 0,
      total:
          _optionalNum(summary['grand_total']) ??
          items.fold<num>(0, (total, item) => total + item.lineTotal),
      currency:
          _optionalString(summary['currency']) ??
          (items.isEmpty ? 'SAR' : items.first.currency),
      shipToCode: _optionalString(delivery['ship_to_code']),
      requestedDeliveryDate: _optionalDate(delivery['requested_delivery_date']),
      deliveryNotes: _optionalString(delivery['notes']),
    );
  }
}

class CartItemModel {
  const CartItemModel({
    required this.itemCode,
    required this.name,
    required this.nameEn,
    required this.imageUrl,
    required this.uom,
    required this.unitsPerCarton,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.currency,
  });

  final String itemCode;
  final String name;
  final String? nameEn;
  final String? imageUrl;
  final String? uom;
  final num? unitsPerCarton;
  final int quantity;
  final num unitPrice;
  final num lineTotal;
  final String currency;

  String localizedName(String languageCode) =>
      languageCode == 'en' && nameEn?.trim().isNotEmpty == true
      ? nameEn!
      : name;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : json;
    final price = json['price'] is Map<String, dynamic>
        ? json['price'] as Map<String, dynamic>
        : json;
    final itemCode = _optionalString(
      json['item_code'] ?? product['item_code'] ?? product['sku'],
    );
    final name = _optionalString(json['name'] ?? product['name']);
    final quantity = _optionalInt(json['quantity']);
    if (itemCode == null || name == null || quantity == null) {
      throw const FormatException('Invalid cart item identity');
    }
    final unitPrice =
        _optionalNum(
          json['unit_price'] ??
              price['unit_price_with_vat'] ??
              price['unit_price'] ??
              json['price'],
        ) ??
        0;
    return CartItemModel(
      itemCode: itemCode,
      name: name,
      nameEn: _optionalString(json['name_en'] ?? product['name_en']),
      imageUrl: _optionalString(json['image_url'] ?? product['image_url']),
      uom: _optionalString(json['uom'] ?? product['uom']),
      unitsPerCarton: _optionalNum(
        json['units_per_carton'] ?? product['units_per_carton'],
      ),
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal:
          _optionalNum(
            json['line_total'] ?? json['subtotal'] ?? json['total'],
          ) ??
          unitPrice * quantity,
      currency: _optionalString(json['currency'] ?? price['currency']) ?? 'SAR',
    );
  }
}

Map<String, dynamic> _map(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value is num) return value.toString();
  return null;
}

num? _optionalNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _optionalInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _optionalDate(Object? value) {
  final raw = _optionalString(value);
  return raw == null ? null : DateTime.tryParse(raw);
}
