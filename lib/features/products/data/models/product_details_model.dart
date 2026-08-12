import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';

class ProductDetailsModel {
  const ProductDetailsModel({
    required this.product,
    required this.barcode,
    required this.brandCode,
    required this.department,
    required this.category,
    required this.productType,
    required this.animal,
    required this.variant,
    required this.unitPrice,
    required this.vatRate,
    required this.isDiscontinued,
  });

  final ProductListingItem product;
  final String? barcode;
  final String? brandCode;
  final String? department;
  final String? category;
  final String? productType;
  final String? animal;
  final String? variant;
  final num? unitPrice;
  final num? vatRate;
  final bool isDiscontinued;

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final classification = _requiredMap(
      json['classification'],
      'product.classification',
    );
    final price = _requiredMap(json['price'], 'product.price');
    return ProductDetailsModel(
      product: ProductListingItem.fromJson(json),
      barcode: _nullableString(json['barcode'], 'product.barcode'),
      brandCode: _nullableScalarString(
        json['brand_code'],
        'product.brand_code',
      ),
      department: _nullableString(
        classification['department'],
        'product.classification.department',
      ),
      category: _nullableString(
        classification['category'],
        'product.classification.category',
      ),
      productType: _nullableString(
        classification['product_type'],
        'product.classification.product_type',
      ),
      animal: _nullableString(
        classification['animal'],
        'product.classification.animal',
      ),
      variant: _nullableString(
        classification['variant'],
        'product.classification.variant',
      ),
      unitPrice: _nullableNum(price['unit_price'], 'product.price.unit_price'),
      vatRate: _nullableNum(price['vat_rate'], 'product.price.vat_rate'),
      isDiscontinued: _requiredBool(
        json['is_discontinued'],
        'product.is_discontinued',
      ),
    );
  }
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

String? _nullableString(Object? value, String field) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$field must be a string or null');
}

String? _nullableScalarString(Object? value, String field) {
  if (value == null) return null;
  if (value is String || value is num) return value.toString();
  throw FormatException('$field must be a string, number, or null');
}

num? _nullableNum(Object? value, String field) {
  if (value == null) return null;
  if (value is num) return value;
  throw FormatException('$field must be a number or null');
}

bool _requiredBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean');
}
