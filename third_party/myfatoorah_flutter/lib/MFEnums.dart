// ignore_for_file: constant_identifier_names, file_names
class MFEnvironment {
  static const String TEST = "TEST";
  static const String LIVE = "LIVE";
}

class MFNotificationOption {
  static const String ALL = "all";
  static const String EMAIL = "eml";
  static const String SMS = "sms";
  static const String LINK = "lnk";
}

class MFCountry {
  static const String KUWAIT = "KWT";
  static const String SAUDIARABIA = "SAU";
  static const String BAHRAIN = "BHR";
  static const String UAE = "ARE";
  static const String QATAR = "QAT";
  static const String OMAN = "OMN";
  static const String JORDAN = "JOD";
  static const String EGYPT = "EGY";
}

class MFLanguage {
  static const String ARABIC = "ar";
  static const String ENGLISH = "en";
}

class MFCurrencyISO {
  static const String KUWAIT_KWD = "KWD";
  static const String SAUDIARABIA_SAR = "SAR";
  static const String BAHRAIN_BHD = "BHD";
  static const String UAE_AED = "AED";
  static const String QATAR_QAR = "QAR";
  static const String OMAN_MOR = "MOR";
  static const String JORDAN_JOD = "JOD";
  static const String UNITEDSTATES_USD = "USD";
  static const String EURO_EUR = "EUR";
}

class MFKeyType {
  static const String INVOICEID = "InvoiceId";
  static const String PAYMENTID = "PaymentId";
}

class MFMobileCountryCodeISO {
  static const String KUWAIT = "+965";
  static const String SAUDIARABIA = "+966";
  static const String UAE = "+971";
  static const String BAHRAIN = "+973";
  static const String QATAR = "+974";
  static const String JORDAN = "+962";
  static const String OMAN = "+968";
  static const String EGYPT = "+20";
}

class MFFontWeight {
  static const String Thin = "Thin";
  static const String ExtraLight = "ExtraLight";
  static const String Light = "Light";
  static const String Normal = "Normal";
  static const String Medium = "Medium";
  static const String SemiBold = "SemiBold";
  static const String Bold = "Bold";
  static const String ExtraBold = "ExtraBold";
  static const String Heavy = "Heavy";
}

class MFFontFamily {
  static const String SansSerif = "SansSerif";
  static const String Arial = "Arial";
  static const String TimesNewRoman = "TimesNewRoman";
  static const String Helvetica = "Helvetica";
  static const String Tahoma = "Tahoma";
  static const String Verdana = "Verdana";
  static const String Monaco = "Monaco";
  static const String Georgia = "Georgia";
  static const String CourierNew = "CourierNew";
  static const String Garamond = "Garamond";
  static const String TrebuchetMS = "TrebuchetMS";
}

class MFRecurringType {
  static const String Daily = "Daily";
  static const String Weekly = "Weekly";
  static const String Monthly = "Monthly";
  static const String Custom = "Custom";
}

class TokenType {
  static const String MFtoken = "mftoken";
  static const String GooglePay = "googlepay";
}

class MFButtonTheme {
  static const int DARK = 1;
  static const int LIGHT = 2;
}

class MFButtonType {
  static const int BUY = 1;
  static const int BOOK = 2;
  static const int CHECKOUT = 3;
  static const int DONATE = 4;
  static const int ORDER = 5;
  static const int PAY = 6;
  static const int SUBSCRIBE = 7;
  static const int PLAIN = 8;
}
