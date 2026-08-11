class HomeResponseModel {
  const HomeResponseModel({required this.sections});

  final List<HomeSectionModel> sections;

  int get sectionCount => sections.length;

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _requiredMap(json['data'], 'data');
    if (json['success'] != true) {
      throw const FormatException('Unsuccessful home response');
    }

    final rawSections = _requiredList(data['sections'], 'data.sections');
    return HomeResponseModel(
      sections: rawSections
          .map(
            (value) => HomeSectionModel.fromJson(
              _requiredMap(value, 'data.sections[]'),
            ),
          )
          .toList(growable: false),
    );
  }
}

enum HomeSectionType { banners, categories, brands, products }

class HomeSectionModel {
  const HomeSectionModel({
    required this.key,
    required this.type,
    required this.title,
    required this.titleEn,
    required this.items,
  });

  final String key;
  final HomeSectionType type;
  final String? title;
  final String? titleEn;
  final List<HomeSectionItemModel> items;

  String localizedTitle(String languageCode) {
    if (languageCode == 'en' && titleEn?.isNotEmpty == true) return titleEn!;
    return title ?? titleEn ?? '';
  }

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final key = _requiredString(json['key'], 'section.key');
    final rawType = _requiredString(json['type'], 'section.type');
    final rawItems = _requiredList(json['items'], '$key.items');

    final HomeSectionType type;
    final HomeSectionItemModel Function(Map<String, dynamic>) parser;
    switch (rawType) {
      case 'banners':
        type = HomeSectionType.banners;
        parser = HomeBannerModel.fromJson;
      case 'categories':
        type = HomeSectionType.categories;
        parser = HomeCategoryModel.fromJson;
      case 'brands':
        type = HomeSectionType.brands;
        parser = HomeBrandModel.fromJson;
      case 'new_products':
      case 'curated_products':
        type = HomeSectionType.products;
        parser = HomeApiProductModel.fromJson;
      default:
        throw FormatException('Unsupported home section type: $rawType');
    }

    return HomeSectionModel(
      key: key,
      type: type,
      title: _optionalString(json['title'], 'section.title'),
      titleEn: _optionalString(json['title_en'], 'section.title_en'),
      items: rawItems
          .map((value) => parser(_requiredMap(value, '$key.items[]')))
          .toList(growable: false),
    );
  }
}

sealed class HomeSectionItemModel {
  const HomeSectionItemModel();
}

class HomeBannerModel extends HomeSectionItemModel {
  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String imageUrl;

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) =>
      HomeBannerModel(
        id: _requiredInt(json['id'], 'banner.id'),
        title: _requiredString(json['title'], 'banner.title'),
        imageUrl: _requiredString(json['image_url'], 'banner.image_url'),
      );
}

class HomeCategoryModel extends HomeSectionItemModel {
  const HomeCategoryModel({required this.value, required this.productCount});

  final String value;
  final int productCount;

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) =>
      HomeCategoryModel(
        value: _requiredString(json['value'], 'category.value'),
        productCount: _requiredInt(
          json['product_count'],
          'category.product_count',
        ),
      );
}

class HomeBrandModel extends HomeSectionItemModel {
  const HomeBrandModel({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.productCount,
  });

  final String code;
  final String name;
  final String imageUrl;
  final int productCount;

  factory HomeBrandModel.fromJson(Map<String, dynamic> json) => HomeBrandModel(
    code: _requiredString(json['code'], 'brand.code'),
    name: _requiredString(json['name'], 'brand.name'),
    imageUrl: _requiredString(json['image_url'], 'brand.image_url'),
    productCount: _requiredInt(json['product_count'], 'brand.product_count'),
  );
}

class HomeApiProductModel extends HomeSectionItemModel {
  const HomeApiProductModel({
    required this.itemCode,
    required this.name,
    required this.nameEn,
    required this.uom,
    required this.unitsPerCarton,
    required this.imageUrl,
    required this.unitPriceWithVat,
    required this.currency,
    required this.availabilityLabel,
    required this.availabilityLabelEn,
    required this.canOrder,
  });

  final String itemCode;
  final String name;
  final String nameEn;
  final String uom;
  final num? unitsPerCarton;
  final String? imageUrl;
  final num unitPriceWithVat;
  final String currency;
  final String availabilityLabel;
  final String availabilityLabelEn;
  final bool canOrder;

  String localizedName(String languageCode) =>
      languageCode == 'en' && nameEn.isNotEmpty ? nameEn : name;

  String localizedAvailability(String languageCode) =>
      languageCode == 'en' && availabilityLabelEn.isNotEmpty
      ? availabilityLabelEn
      : availabilityLabel;

  factory HomeApiProductModel.fromJson(Map<String, dynamic> json) {
    final price = _requiredMap(json['price'], 'product.price');
    final availability = _requiredMap(
      json['availability'],
      'product.availability',
    );
    return HomeApiProductModel(
      itemCode: _requiredString(json['item_code'], 'product.item_code'),
      name: _requiredString(json['name'], 'product.name'),
      nameEn: _requiredString(json['name_en'], 'product.name_en'),
      uom: _requiredString(json['uom'], 'product.uom'),
      unitsPerCarton: _optionalNum(
        json['units_per_carton'],
        'product.units_per_carton',
      ),
      imageUrl: _optionalString(json['image_url'], 'product.image_url'),
      unitPriceWithVat: _requiredNum(
        price['unit_price_with_vat'],
        'product.price.unit_price_with_vat',
      ),
      currency: _requiredString(price['currency'], 'product.price.currency'),
      availabilityLabel: _requiredString(
        availability['label'],
        'product.availability.label',
      ),
      availabilityLabelEn: _requiredString(
        availability['label_en'],
        'product.availability.label_en',
      ),
      canOrder: _requiredBool(
        availability['can_order'],
        'product.availability.can_order',
      ),
    );
  }
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

List<Object?> _requiredList(Object? value, String field) {
  if (value is List) return value.cast<Object?>();
  throw FormatException('$field must be an array');
}

String _requiredString(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  if (value is num) return value.toString();
  throw FormatException('$field must be a non-empty string');
}

String? _optionalString(Object? value, String field) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$field must be a string or null');
}

num _requiredNum(Object? value, String field) {
  if (value is num) return value;
  throw FormatException('$field must be a number');
}

num? _optionalNum(Object? value, String field) {
  if (value == null) return null;
  if (value is num) return value;
  throw FormatException('$field must be a number or null');
}

int _requiredInt(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer');
}

bool _requiredBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean');
}
