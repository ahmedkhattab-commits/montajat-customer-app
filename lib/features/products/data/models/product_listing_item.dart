class ProductListingItem {
  const ProductListingItem({
    required this.itemCode,
    required this.name,
    required this.nameEn,
    required this.uom,
    required this.unitsPerCarton,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.availabilityLabel,
    required this.availabilityLabelEn,
    required this.isAvailable,
    this.availableQuantity,
  });

  final String itemCode;
  final String? name;
  final String? nameEn;
  final String uom;
  final num? unitsPerCarton;
  final String? imageUrl;
  final num? price;
  final String currency;
  final String availabilityLabel;
  final String availabilityLabelEn;
  final bool isAvailable;
  final num? availableQuantity;

  String localizedName(String languageCode) {
    final preferred = languageCode == 'en' ? nameEn : name;
    final fallback = languageCode == 'en' ? name : nameEn;
    return preferred?.trim().isNotEmpty == true
        ? preferred!.trim()
        : fallback?.trim().isNotEmpty == true
        ? fallback!.trim()
        : itemCode;
  }

  String localizedAvailability(String languageCode) =>
      languageCode == 'en' && availabilityLabelEn.isNotEmpty
      ? availabilityLabelEn
      : availabilityLabel;

  factory ProductListingItem.fromJson(Map<String, dynamic> json) {
    final priceData = _requiredMap(json['price'], 'product.price');
    final availability = _requiredMap(
      json['availability'],
      'product.availability',
    );
    return ProductListingItem(
      itemCode: _requiredString(json['item_code'], 'product.item_code'),
      name: _nullableString(json['name'], 'product.name'),
      nameEn: _nullableString(json['name_en'], 'product.name_en'),
      uom: _stringOrEmpty(json['uom'], 'product.uom'),
      unitsPerCarton: _nullableNum(
        json['units_per_carton'],
        'product.units_per_carton',
      ),
      imageUrl: _nullableString(json['image_url'], 'product.image_url'),
      price: _nullableNum(
        priceData['unit_price_with_vat'],
        'product.price.unit_price_with_vat',
      ),
      currency: _requiredString(
        priceData['currency'],
        'product.price.currency',
      ),
      availabilityLabel: _requiredString(
        availability['label'],
        'product.availability.label',
      ),
      availabilityLabelEn: _requiredString(
        availability['label_en'],
        'product.availability.label_en',
      ),
      isAvailable: _requiredBool(
        availability['can_order'],
        'product.availability.can_order',
      ),
      availableQuantity: _nullableFlexibleNum(
        availability['available_quantity'] ??
            availability['available_qty'] ??
            availability['quantity'] ??
            availability['available'] ??
            json['available_quantity'] ??
            json['available_qty'] ??
            json['stock_quantity'],
        'product.availability.available_quantity',
      ),
    );
  }
}

class ProductsPageModel {
  const ProductsPageModel({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });

  final List<ProductListingItem> items;
  final int currentPage;
  final bool hasMore;

  factory ProductsPageModel.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true || json['data'] is! List) {
      throw const FormatException('Invalid products response');
    }
    final meta = _requiredMap(json['meta'], 'meta');
    final pagination = _requiredMap(meta['pagination'], 'meta.pagination');
    final currentPage = pagination['current_page'];
    final hasMore = pagination['has_more'];
    if (currentPage is! int || hasMore is! bool) {
      throw const FormatException('Invalid products pagination');
    }
    return ProductsPageModel(
      items: (json['data'] as List)
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid product item');
            }
            return ProductListingItem.fromJson(item);
          })
          .toList(growable: false),
      currentPage: currentPage,
      hasMore: hasMore,
    );
  }
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

String _requiredString(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  if (value is num) return value.toString();
  throw FormatException('$field must be a non-empty string');
}

String _stringOrEmpty(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('$field must be a string');
}

String? _nullableString(Object? value, String field) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$field must be a string or null');
}

num? _nullableNum(Object? value, String field) {
  if (value == null) return null;
  if (value is num) return value;
  throw FormatException('$field must be a number or null');
}

num? _nullableFlexibleNum(Object? value, String field) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('$field must be a number or null');
}

bool _requiredBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean');
}
