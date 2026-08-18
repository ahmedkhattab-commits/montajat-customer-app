import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

abstract final class MyFatoorahConfig {
  static const apiKey = String.fromEnvironment('MYFATOORAH_API_KEY');
  static const environmentName = String.fromEnvironment(
    'MYFATOORAH_ENVIRONMENT',
    defaultValue: 'test',
  );
  static const googlePayMerchantId = String.fromEnvironment(
    'MYFATOORAH_GOOGLE_PAY_MERCHANT_ID',
  );

  static bool get hasApiKey => apiKey.trim().isNotEmpty;

  static String get environment => environmentName.toLowerCase() == 'live'
      ? MFEnvironment.LIVE
      : MFEnvironment.TEST;
}
