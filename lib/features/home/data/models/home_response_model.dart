class HomeResponseModel {
  const HomeResponseModel({
    required this.sections,
    this.expiryOffers = const [],
  });

  final List<HomeSectionModel> sections;
  final List<HomeExpiryOfferModel> expiryOffers;

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

  HomeResponseModel withExpiryOffers(List<HomeExpiryOfferModel> offers) {
    if (offers.isEmpty ||
        sections.any((item) => item.key == 'offers_for_you')) {
      return HomeResponseModel(sections: sections, expiryOffers: offers);
    }

    final offersSection = HomeSectionModel(
      key: 'offers_for_you',
      type: HomeSectionType.banners,
      title: 'عروض لك',
      titleEn: 'Offers for you',
      items: const [],
    );
    final updatedSections = List<HomeSectionModel>.of(sections);
    final discountsIndex = updatedSections.indexWhere(
      (item) => item.key == 'discounts',
    );
    updatedSections.insert(
      discountsIndex == -1 ? updatedSections.length : discountsIndex,
      offersSection,
    );
    return HomeResponseModel(sections: updatedSections, expiryOffers: offers);
  }

  HomeResponseModel withBanners(List<HomeBannerModel> banners) {
    final bannerSection = HomeSectionModel(
      key: 'hero_banners',
      type: HomeSectionType.banners,
      title: null,
      titleEn: null,
      items: banners,
    );
    final updatedSections = <HomeSectionModel>[];
    var inserted = false;
    for (final section in sections) {
      if (section.key == 'hero_banners') {
        if (!inserted) {
          updatedSections.add(bannerSection);
          inserted = true;
        }
        continue;
      }
      updatedSections.add(section);
    }
    if (!inserted) updatedSections.insert(0, bannerSection);
    return HomeResponseModel(
      sections: updatedSections,
      expiryOffers: expiryOffers,
    );
  }

  static List<HomeBannerModel> bannersFromJson(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw const FormatException('Unsuccessful banners response');
    }
    final rawBanners = _requiredList(json['data'], 'data');
    return rawBanners
        .map((value) => HomeBannerModel.fromJson(_requiredMap(value, 'data[]')))
        .toList(growable: false);
  }

  static List<HomeExpiryOfferModel> expiryOffersFromJson(
    Map<String, dynamic> json,
  ) {
    if (json['success'] != true) {
      throw const FormatException('Unsuccessful expiry offers response');
    }
    final rawOffers = _requiredList(json['data'], 'data');
    return rawOffers
        .map(
          (value) =>
              HomeExpiryOfferModel.fromJson(_requiredMap(value, 'data[]')),
        )
        .toList(growable: false);
  }
}

class HomeExpiryOfferModel {
  const HomeExpiryOfferModel({
    required this.offerId,
    required this.itemCode,
    required this.name,
    required this.imageUrl,
    required this.expiryDate,
    required this.daysLeft,
    required this.basePrice,
    required this.offerPrice,
    required this.discountPercent,
    required this.currency,
    required this.availableQuantity,
    required this.suggestedQuantity,
    required this.message,
  });

  final int offerId;
  final String itemCode;
  final String name;
  final String? imageUrl;
  final DateTime expiryDate;
  final int daysLeft;
  final num basePrice;
  final num offerPrice;
  final num discountPercent;
  final String currency;
  final num availableQuantity;
  final num suggestedQuantity;
  final String message;

  factory HomeExpiryOfferModel.fromJson(Map<String, dynamic> json) {
    final expiry = _requiredMap(json['expiry'], 'offer.expiry');
    final pricing = _requiredMap(json['pricing'], 'offer.pricing');
    final quantity = _requiredMap(json['quantity'], 'offer.quantity');
    final why = _requiredMap(json['why'], 'offer.why');
    final expiryDate = DateTime.tryParse(
      _requiredString(expiry['date'], 'offer.expiry.date'),
    );
    if (expiryDate == null) {
      throw const FormatException('offer.expiry.date must be an ISO date');
    }

    return HomeExpiryOfferModel(
      offerId: _requiredInt(json['offer_id'], 'offer.offer_id'),
      itemCode: _requiredString(json['item_code'], 'offer.item_code'),
      name: _requiredString(json['name'], 'offer.name'),
      imageUrl: _optionalString(json['image_url'], 'offer.image_url'),
      expiryDate: expiryDate,
      daysLeft: _requiredInt(expiry['days_left'], 'offer.expiry.days_left'),
      basePrice: _requiredNum(
        pricing['base_price'],
        'offer.pricing.base_price',
      ),
      offerPrice: _requiredNum(
        pricing['offer_price'],
        'offer.pricing.offer_price',
      ),
      discountPercent: _requiredNum(
        pricing['discount_pct'],
        'offer.pricing.discount_pct',
      ),
      currency: _requiredString(pricing['currency'], 'offer.pricing.currency'),
      availableQuantity: _requiredNum(
        quantity['available'],
        'offer.quantity.available',
      ),
      suggestedQuantity: _requiredNum(
        quantity['suggested'],
        'offer.quantity.suggested',
      ),
      message: _requiredString(why['message'], 'offer.why.message'),
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

  HomeSectionModel copyWithItems(List<HomeSectionItemModel> newItems) =>
      HomeSectionModel(
        key: key,
        type: type,
        title: title,
        titleEn: titleEn,
        items: newItems,
      );

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
        id: _intOrZero(json['id'], 'banner.id'),
        title: _stringOrEmpty(json['title'], 'banner.title'),
        imageUrl: _stringOrEmpty(json['image_url'], 'banner.image_url'),
      );
}

class HomeCategoryModel extends HomeSectionItemModel {
  const HomeCategoryModel({required this.value, required this.productCount});

  final String value;
  final int productCount;

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) =>
      HomeCategoryModel(
        value: _stringOrEmpty(json['value'], 'category.value'),
        productCount: _intOrZero(
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
    code: _stringOrEmpty(json['code'], 'brand.code'),
    name: _stringOrEmpty(json['name'], 'brand.name'),
    imageUrl: _stringOrEmpty(json['image_url'], 'brand.image_url'),
    productCount: _intOrZero(json['product_count'], 'brand.product_count'),
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
    required this.cartonPrice,
    required this.currency,
    required this.availabilityLabel,
    required this.availabilityLabelEn,
    required this.canOrder,
    this.availableQuantity,
  });

  final String itemCode;
  final String name;
  final String nameEn;
  final String uom;
  final num? unitsPerCarton;
  final String? imageUrl;
  final num? cartonPrice;
  final String currency;
  final String availabilityLabel;
  final String availabilityLabelEn;
  final bool canOrder;
  final num? availableQuantity;

  String localizedName(String languageCode) =>
      languageCode == 'en' && nameEn.isNotEmpty ? nameEn : name;

  String localizedAvailability(String languageCode) =>
      languageCode == 'en' && availabilityLabelEn.isNotEmpty
      ? availabilityLabelEn
      : availabilityLabel;

  factory HomeApiProductModel.fromJson(Map<String, dynamic> json) {
    final price = _mapOrEmpty(json['price'], 'product.price');
    final availability = _mapOrEmpty(
      json['availability'],
      'product.availability',
    );
    return HomeApiProductModel(
      itemCode: _stringOrEmpty(json['item_code'], 'product.item_code'),
      name: _stringOrEmpty(json['name'], 'product.name'),
      nameEn: _stringOrEmpty(json['name_en'], 'product.name_en'),
      uom: _stringOrEmpty(json['uom'], 'product.uom'),
      unitsPerCarton: _optionalNum(
        json['units_per_carton'],
        'product.units_per_carton',
      ),
      imageUrl: _optionalString(json['image_url'], 'product.image_url'),
      cartonPrice: _optionalNum(
        price['carton_price'],
        'product.price.carton_price',
      ),
      currency: _stringOrEmpty(price['currency'], 'product.price.currency'),
      availabilityLabel: _stringOrEmpty(
        availability['label'],
        'product.availability.label',
      ),
      availabilityLabelEn: _stringOrEmpty(
        availability['label_en'],
        'product.availability.label_en',
      ),
      canOrder: _boolOrFalse(
        availability['can_order'],
        'product.availability.can_order',
      ),
      availableQuantity: _optionalFlexibleNum(
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

num? _optionalFlexibleNum(Object? value, String field) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('$field must be a number or null');
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

Map<String, dynamic> _mapOrEmpty(Object? value, String field) {
  if (value == null) return const {};
  return _requiredMap(value, field);
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

String _stringOrEmpty(Object? value, String field) {
  if (value == null) return '';
  return _requiredString(value, field);
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

int _intOrZero(Object? value, String field) {
  if (value == null) return 0;
  return _requiredInt(value, field);
}

bool _requiredBool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean');
}

bool _boolOrFalse(Object? value, String field) {
  if (value == null) return false;
  return _requiredBool(value, field);
}
