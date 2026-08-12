class ProfileModel {
  const ProfileModel({
    required this.userId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.role,
    required this.accountName,
    required this.cardCode,
    required this.city,
    required this.country,
    required this.canPlaceOrders,
    required this.canViewFinancials,
    required this.credit,
    required this.addressCount,
  });

  final int userId;
  final String name;
  final String mobile;
  final String? email;
  final String role;
  final String accountName;
  final String cardCode;
  final String? city;
  final String? country;
  final bool canPlaceOrders;
  final bool canViewFinancials;
  final CreditModel credit;
  final int addressCount;

  factory ProfileModel.fromResponses(
    Map<String, dynamic> profileJson,
    Map<String, dynamic> creditJson,
    Map<String, dynamic> addressesJson,
  ) {
    final profileData = _map(profileJson['data'], 'profile.data');
    final user = _map(profileData['user'], 'profile.user');
    final account = _map(profileData['account'], 'profile.account');
    final permissions = _map(user['permissions'], 'profile.permissions');
    final addresses = addressesJson['data'];
    if (addresses is! List) {
      throw const FormatException('profile.addresses must be an array');
    }
    return ProfileModel(
      userId: _int(user['id'], 'profile.user.id'),
      name: _string(user['name'], 'profile.user.name'),
      mobile: _string(user['mobile'], 'profile.user.mobile'),
      email: _nullableString(user['email'], 'profile.user.email'),
      role: _string(user['role'], 'profile.user.role'),
      accountName: _string(account['name'], 'profile.account.name'),
      cardCode: _string(account['card_code'], 'profile.account.card_code'),
      city: _nullableString(account['city'], 'profile.account.city'),
      country: _nullableString(account['country'], 'profile.account.country'),
      canPlaceOrders: _bool(
        permissions['can_place_orders'],
        'profile.permissions.can_place_orders',
      ),
      canViewFinancials: _bool(
        permissions['can_view_financials'],
        'profile.permissions.can_view_financials',
      ),
      credit: CreditModel.fromJson(_map(creditJson['data'], 'credit.data')),
      addressCount: addresses.length,
    );
  }
}

class CreditModel {
  const CreditModel({
    required this.hasLimit,
    required this.limit,
    required this.used,
    required this.available,
    required this.currentBalance,
    required this.openOrdersBalance,
    required this.currency,
    required this.isExceeded,
  });

  final bool hasLimit;
  final num? limit;
  final num used;
  final num? available;
  final num currentBalance;
  final num openOrdersBalance;
  final String currency;
  final bool isExceeded;

  factory CreditModel.fromJson(Map<String, dynamic> json) => CreditModel(
    hasLimit: _bool(json['has_limit'], 'credit.has_limit'),
    limit: _nullableNum(json['limit'], 'credit.limit'),
    used: _num(json['used'], 'credit.used'),
    available: _nullableNum(json['available'], 'credit.available'),
    currentBalance: _num(json['current_balance'], 'credit.current_balance'),
    openOrdersBalance: _num(
      json['open_orders_balance'],
      'credit.open_orders_balance',
    ),
    currency: _string(json['currency'], 'credit.currency'),
    isExceeded: _bool(json['is_exceeded'], 'credit.is_exceeded'),
  );
}

Map<String, dynamic> _map(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

String _string(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  if (value is num) return value.toString();
  throw FormatException('$field must be a non-empty string');
}

String? _nullableString(Object? value, String field) {
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$field must be a string or null');
}

int _int(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer');
}

num _num(Object? value, String field) {
  if (value is num) return value;
  throw FormatException('$field must be a number');
}

num? _nullableNum(Object? value, String field) {
  if (value == null) return null;
  return _num(value, field);
}

bool _bool(Object? value, String field) {
  if (value is bool) return value;
  throw FormatException('$field must be a boolean');
}
