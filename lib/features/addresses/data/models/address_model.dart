class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.city,
    required this.cityCode,
    required this.district,
    required this.street,
    required this.buildingNumber,
    required this.postalCode,
    required this.contactPerson,
    required this.phone,
    required this.notes,
    required this.isPreferred,
    this.code,
    this.typeLabel,
    this.state,
    this.country,
    this.formatted,
    this.isSapDefault = false,
    this.isHidden = false,
  });

  final int id;
  final String label;
  final String? city;
  final String? cityCode;
  final String? district;
  final String? street;
  final String? buildingNumber;
  final String? postalCode;
  final String? contactPerson;
  final String? phone;
  final String? notes;
  final bool isPreferred;
  final String? code;
  final String? typeLabel;
  final String? state;
  final String? country;
  final String? formatted;
  final bool isSapDefault;
  final bool isHidden;

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: _int(json['id'], 'address.id'),
    label:
        _firstString(json, const ['label', 'name', 'address_name']) ??
        'Address ${json['id']}',
    city: _firstString(json, const ['city', 'city_name']),
    cityCode: _firstString(json, const ['city_code', 'city']),
    district: _firstString(json, const ['district', 'area', 'county']),
    street: _firstString(json, const ['street', 'street_name', 'address']),
    buildingNumber: _firstString(json, const [
      'building_number',
      'building_no',
      'building',
    ]),
    postalCode: _firstString(json, const ['postal_code', 'zip_code']),
    contactPerson: _firstString(json, const ['contact_person', 'contact_name']),
    phone: _firstString(json, const ['phone', 'mobile']),
    notes: _firstString(json, const ['notes', 'delivery_instructions']),
    isPreferred: json['is_preferred'] == true || json['preferred'] == true,
    code: _firstString(json, const ['code']),
    typeLabel: _firstString(json, const ['type_label']),
    state: _firstString(json, const ['state']),
    country: _firstString(json, const ['country']),
    formatted: _firstString(json, const ['formatted']),
    isSapDefault: json['is_sap_default'] == true || json['is_default'] == true,
    isHidden: json['is_hidden'] == true,
  );

  Map<String, dynamic> toPortalUpdate() => {
    'label': label,
    'city_code': cityCode,
    'district': district,
    'street': street,
    'building_number': buildingNumber,
    'postal_code': postalCode,
    'contact_person': contactPerson,
    'phone': phone,
    'notes': notes,
  }..removeWhere((_, value) => value == null);
}

class CityModel {
  const CityModel({required this.code, required this.name});

  final String code;
  final String name;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final code = _firstString(json, const ['code', 'city_code', 'value']);
    final name = _firstString(json, const ['name', 'label', 'city']);
    if (code == null || name == null) {
      throw const FormatException('Invalid city item');
    }
    return CityModel(code: code, name: name);
  }

  factory CityModel.fromValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return CityModel(code: value.trim(), name: value.trim());
    }
    if (value is Map<String, dynamic>) return CityModel.fromJson(value);
    throw const FormatException('Invalid city item');
  }
}

int _int(Object? value, String field) {
  if (value is int) return value;
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('$field must be an integer');
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is num) return value.toString();
  }
  return null;
}
