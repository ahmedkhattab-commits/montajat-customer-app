enum OnlinePaymentMethodType { card, stcPay, googlePay, applePay, other }

class OnlinePaymentMethodModel {
  const OnlinePaymentMethodModel({
    required this.gateway,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
    required this.serviceCharge,
    required this.totalAmount,
    required this.currency,
  });

  final String gateway;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final double serviceCharge;
  final double totalAmount;
  final String currency;

  String localizedName(String languageCode) =>
      languageCode == 'en' && nameEn.isNotEmpty ? nameEn : nameAr;

  OnlinePaymentMethodType get type => switch (gateway.toLowerCase()) {
    'md' ||
    'vm' ||
    'uaecc' ||
    'ae' ||
    'b' ||
    'kn' => OnlinePaymentMethodType.card,
    'stc' => OnlinePaymentMethodType.stcPay,
    'gp' => OnlinePaymentMethodType.googlePay,
    'ap' => OnlinePaymentMethodType.applePay,
    _ => OnlinePaymentMethodType.other,
  };

  factory OnlinePaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final gateway = _string(json['gateway'] ?? json['code']);
    if (gateway == null) {
      throw const FormatException('payment method gateway is required');
    }
    final nameAr =
        _string(
          json['name_ar'] ?? json['payment_method_ar'] ?? json['label'],
        ) ??
        _defaultPaymentMethodName(gateway, isArabic: true);
    final nameEn =
        _string(
          json['name_en'] ?? json['payment_method_en'] ?? json['label_en'],
        ) ??
        _defaultPaymentMethodName(gateway, isArabic: false);
    return OnlinePaymentMethodModel(
      gateway: gateway,
      nameAr: nameAr,
      nameEn: nameEn,
      imageUrl: _string(json['image_url']),
      serviceCharge: _number(
        json['service_charge'] ?? json['fee'],
        'service_charge',
      ),
      totalAmount: _number(
        json['total_amount'] ?? json['total'],
        'total_amount',
      ),
      currency: (_string(json['currency'] ?? json['currency_iso']) ?? 'SAR')
          .toUpperCase(),
    );
  }
}

class OnlinePaymentModel {
  const OnlinePaymentModel({
    required this.reference,
    required this.status,
    required this.paymentUrl,
    required this.statusReason,
    required this.amount,
    required this.currency,
  });

  final String reference;
  final String status;
  final String? paymentUrl;
  final String? statusReason;
  final double? amount;
  final String? currency;

  bool get isPaid => const {
    'paid',
    'success',
    'succeeded',
    'completed',
  }.contains(status.toLowerCase());

  bool get isTerminalFailure =>
      const {'failed', 'cancelled', 'expired'}.contains(status.toLowerCase());

  factory OnlinePaymentModel.fromJson(Map<String, dynamic> json) {
    final reference = _string(json['reference']);
    if (reference == null) {
      throw const FormatException('payment reference is required');
    }
    return OnlinePaymentModel(
      reference: reference,
      status: _string(json['status']) ?? 'pending',
      paymentUrl: _string(json['payment_url']),
      statusReason: _string(json['status_reason']),
      amount: _nullableNumber(json['amount']),
      currency: _string(json['currency'])?.toUpperCase(),
    );
  }
}

class OnlinePaymentSessionModel {
  const OnlinePaymentSessionModel({
    required this.sessionId,
    required this.countryCode,
  });

  final String sessionId;
  final String countryCode;

  factory OnlinePaymentSessionModel.fromJson(Map<String, dynamic> json) {
    final sessionId = _string(json['session_id'] ?? json['SessionId']);
    if (sessionId == null) {
      throw const FormatException('payment session_id is required');
    }
    return OnlinePaymentSessionModel(
      sessionId: sessionId,
      countryCode:
          (_string(json['country_code'] ?? json['CountryCode']) ?? 'SAU')
              .toUpperCase(),
    );
  }
}

String _defaultPaymentMethodName(String gateway, {required bool isArabic}) {
  return switch (gateway.toLowerCase()) {
    'md' => isArabic ? 'مدى' : 'Mada',
    'stc' => 'STC Pay',
    'gp' => 'Google Pay',
    'ap' => 'Apple Pay',
    _ => gateway,
  };
}

String? _string(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value is num) return value.toString();
  return null;
}

double _number(Object? value, String field) {
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value?.toString() ?? '');
  if (parsed != null) return parsed;
  throw FormatException('$field must be a number');
}

double? _nullableNumber(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
