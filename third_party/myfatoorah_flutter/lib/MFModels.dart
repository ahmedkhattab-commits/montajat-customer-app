// ignore_for_file: file_names

import 'package:myfatoorah_flutter/MFUtils.dart';
import 'package:myfatoorah_flutter/MFEnums.dart';

class MFSendPaymentResponse {
  num? invoiceId;
  String? invoiceURL;
  String? customerReference;
  String? userDefinedField;

  MFSendPaymentResponse(
      {this.invoiceId,
      this.invoiceURL,
      this.customerReference,
      this.userDefinedField});

  MFSendPaymentResponse.fromJson(Map<String, dynamic> json) {
    invoiceId = json['InvoiceId'];
    invoiceURL = json['InvoiceURL'];
    customerReference = json['CustomerReference'];
    userDefinedField = json['UserDefinedField'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceId'] = invoiceId;
    data['InvoiceURL'] = invoiceURL;
    data['CustomerReference'] = customerReference;
    data['UserDefinedField'] = userDefinedField;
    return data;
  }
}

class MFSendPaymentRequest {
  String? customerName;
  String? notificationOption;
  String? displayCurrencyIso;
  String? mobileCountryCode;
  String? customerMobile;
  String? customerEmail;
  num? invoiceValue;
  String? language;
  String? customerReference;
  String? customerCivilId;
  String? userDefinedField;
  MFCustomerAddres? customerAddress;
  String? expiryDate;
  List<MFInvoiceItem>? invoiceItems;
  // int? shippingMethod;
  // MFShippingConsignee? shippingConsignee;
  // List<MFSupplier>? suppliers;

  MFSendPaymentRequest({
    this.customerName,
    this.notificationOption,
    this.displayCurrencyIso,
    this.mobileCountryCode,
    this.customerMobile,
    this.customerEmail,
    this.invoiceValue,
    this.language,
    this.customerReference,
    this.customerCivilId,
    this.userDefinedField,
    this.customerAddress,
    this.expiryDate,
    this.invoiceItems,
    // this.shippingMethod,
    // this.shippingConsignee,
    // this.suppliers
  });

  MFSendPaymentRequest.fromJson(Map<String, dynamic> json) {
    customerName = json['CustomerName'];
    notificationOption = json['NotificationOption'];
    displayCurrencyIso = json['DisplayCurrencyIso'];
    mobileCountryCode = json['MobileCountryCode'];
    customerMobile = json['CustomerMobile'];
    customerEmail = json['CustomerEmail'];
    invoiceValue = json['InvoiceValue'];
    language = json['Language'];
    customerReference = json['CustomerReference'];
    customerCivilId = json['CustomerCivilId'];
    userDefinedField = json['UserDefinedField'];
    customerAddress = json['CustomerAddress'] != null
        ? MFCustomerAddres.fromJson(json['CustomerAddress'])
        : null;
    expiryDate = json['ExpiryDate'];
    if (json['InvoiceItems'] != null) {
      invoiceItems = <MFInvoiceItem>[];
      json['InvoiceItems'].forEach((v) {
        invoiceItems!.add(MFInvoiceItem.fromJson(v));
      });
    }
    // shippingMethod = json['ShippingMethod'];
    // shippingConsignee = json['ShippingConsignee'] != null
    //     ? MFShippingConsignee.fromJson(json['ShippingConsignee'])
    //     : null;
    // if (json['Suppliers'] != null) {
    //   suppliers = <MFSupplier>[];
    //   json['Suppliers'].forEach((v) {
    //     suppliers!.add(MFSupplier.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerName'] = customerName;
    data['NotificationOption'] = notificationOption;
    data['DisplayCurrencyIso'] = displayCurrencyIso;
    data['MobileCountryCode'] = mobileCountryCode;
    data['CustomerMobile'] = customerMobile;
    data['CustomerEmail'] = customerEmail;
    data['InvoiceValue'] = invoiceValue;
    data['Language'] = language;
    data['CustomerReference'] = customerReference;
    data['CustomerCivilId'] = customerCivilId;
    data['UserDefinedField'] = userDefinedField;
    if (customerAddress != null) {
      data['CustomerAddress'] = customerAddress!.toJson();
    }
    data['ExpiryDate'] = expiryDate;
    if (invoiceItems != null) {
      data['InvoiceItems'] = invoiceItems!.map((v) => v.toJson()).toList();
    }
    // data['ShippingMethod'] = shippingMethod;
    // if (shippingConsignee != null) {
    //   data['ShippingConsignee'] = shippingConsignee!.toJson();
    // }
    // if (suppliers != null) {
    //   data['Suppliers'] = suppliers!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class MFCustomerAddres {
  String? block;
  String? street;
  String? houseBuildingNo;
  String? addressInstructions;

  MFCustomerAddres(
      {this.block,
      this.street,
      this.houseBuildingNo,
      this.addressInstructions});

  MFCustomerAddres.fromJson(Map<String, dynamic> json) {
    block = json['Block'];
    street = json['Street'];
    houseBuildingNo = json['HouseBuildingNo'];
    addressInstructions = json['AddressInstructions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Block'] = block;
    data['Street'] = street;
    data['HouseBuildingNo'] = houseBuildingNo;
    data['AddressInstructions'] = addressInstructions;
    return data;
  }
}

class MFInvoiceItem {
  String? itemName;
  int? quantity;
  num? unitPrice;
  int? weight;
  int? width;
  int? height;
  int? depth;

  MFInvoiceItem(
      {this.itemName,
      this.quantity,
      this.unitPrice,
      this.weight,
      this.width,
      this.height,
      this.depth});

  MFInvoiceItem.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    quantity = (json['Quantity'] as num?)?.toInt();
    unitPrice = json['UnitPrice'];
    weight = json['Weight'];
    width = json['Width'];
    height = json['Height'];
    depth = json['Depth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemName'] = itemName;
    data['Quantity'] = quantity;
    data['UnitPrice'] = unitPrice;
    data['Weight'] = weight;
    data['Width'] = width;
    data['Height'] = height;
    data['Depth'] = depth;
    return data;
  }
}

// class MFShippingConsignee {
//   String? personName;
//   String? mobile;
//   String? emailAddress;
//   String? lineAddress;
//   String? cityName;
//   String? postalCode;
//   String? countryCode;

//   MFShippingConsignee(
//       {this.personName,
//       this.mobile,
//       this.emailAddress,
//       this.lineAddress,
//       this.cityName,
//       this.postalCode,
//       this.countryCode});

//   MFShippingConsignee.fromJson(Map<String, dynamic> json) {
//     personName = json['PersonName'];
//     mobile = json['Mobile'];
//     emailAddress = json['EmailAddress'];
//     lineAddress = json['LineAddress'];
//     cityName = json['CityName'];
//     postalCode = json['PostalCode'];
//     countryCode = json['CountryCode'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['PersonName'] = personName;
//     data['Mobile'] = mobile;
//     data['EmailAddress'] = emailAddress;
//     data['LineAddress'] = lineAddress;
//     data['CityName'] = cityName;
//     data['PostalCode'] = postalCode;
//     data['CountryCode'] = countryCode;
//     return data;
//   }
// }

class MFSupplier {
  int? supplierCode;
  String? supplierName;
  num? invoiceShare;
  num? proposedShare;
  num? depositShare;

  MFSupplier(
      {this.supplierCode,
      this.supplierName,
      this.invoiceShare,
      this.proposedShare,
      this.depositShare});

  MFSupplier.fromJson(Map<String, dynamic> json) {
    supplierCode = (json['SupplierCode'] as num?)?.toInt();
    supplierName = json['SupplierName'];
    invoiceShare = json['InvoiceShare'];
    proposedShare = json['ProposedShare'];
    depositShare = json['DepositShare'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SupplierCode'] = supplierCode;
    data['SupplierName'] = supplierName;
    data['InvoiceShare'] = invoiceShare;
    data['ProposedShare'] = proposedShare;
    data['DepositShare'] = depositShare;
    return data;
  }
}

class MFInitiatePaymentResponse {
  List<MFPaymentMethod>? paymentMethods;

  MFInitiatePaymentResponse({this.paymentMethods});

  MFInitiatePaymentResponse.fromJson(Map<String, dynamic> json) {
    if (json['PaymentMethods'] != null) {
      paymentMethods = <MFPaymentMethod>[];
      json['PaymentMethods'].forEach((v) {
        paymentMethods!.add(MFPaymentMethod.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (paymentMethods != null) {
      data['PaymentMethods'] = paymentMethods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MFPaymentMethod {
  int? paymentMethodId;
  String? paymentMethodAr;
  String? paymentMethodEn;
  String? paymentMethodCode;
  bool? isDirectPayment;
  num? serviceCharge;
  num? totalAmount;
  String? currencyIso;
  String? imageUrl;
  bool? isEmbeddedSupported;
  String? paymentCurrencyIso;

  MFPaymentMethod(
      {this.paymentMethodId,
      this.paymentMethodAr,
      this.paymentMethodEn,
      this.paymentMethodCode,
      this.isDirectPayment,
      this.serviceCharge,
      this.totalAmount,
      this.currencyIso,
      this.imageUrl,
      this.isEmbeddedSupported,
      this.paymentCurrencyIso});

  MFPaymentMethod.fromJson(Map<String, dynamic> json) {
    paymentMethodId = json['PaymentMethodId'];
    paymentMethodAr = json['PaymentMethodAr'];
    paymentMethodEn = json['PaymentMethodEn'];
    paymentMethodCode = json['PaymentMethodCode'];
    isDirectPayment = json['IsDirectPayment'];
    serviceCharge = json['ServiceCharge'];
    totalAmount = json['TotalAmount'];
    currencyIso = json['CurrencyIso'];
    imageUrl = json['ImageUrl'];
    isEmbeddedSupported = json['IsEmbeddedSupported'];
    paymentCurrencyIso = json['PaymentCurrencyIso'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PaymentMethodId'] = paymentMethodId;
    data['PaymentMethodAr'] = paymentMethodAr;
    data['PaymentMethodEn'] = paymentMethodEn;
    data['PaymentMethodCode'] = paymentMethodCode;
    data['IsDirectPayment'] = isDirectPayment;
    data['ServiceCharge'] = serviceCharge;
    data['TotalAmount'] = totalAmount;
    data['CurrencyIso'] = currencyIso;
    data['ImageUrl'] = imageUrl;
    data['IsEmbeddedSupported'] = isEmbeddedSupported;
    data['PaymentCurrencyIso'] = paymentCurrencyIso;
    return data;
  }
}

class MFInitiatePaymentRequest {
  num? invoiceAmount;
  String? currencyIso;

  MFInitiatePaymentRequest({this.invoiceAmount, this.currencyIso});

  MFInitiatePaymentRequest.fromJson(Map<String, dynamic> json) {
    invoiceAmount = json['InvoiceAmount'];
    currencyIso = json['CurrencyIso'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceAmount'] = invoiceAmount;
    data['CurrencyIso'] = currencyIso;
    return data;
  }
}

class MFInitiateSessionResponse {
  String sessionId = "";
  String countryCode = "";
  List<CustomerTokens>? customerTokens;

  MFInitiateSessionResponse(
      {this.sessionId = "", this.countryCode = "", this.customerTokens});

  MFInitiateSessionResponse.fromJson(Map<String, dynamic> json) {
    sessionId = json['SessionId'];
    countryCode = json['CountryCode'];
    if (json['CustomerTokens'] != null) {
      customerTokens = <CustomerTokens>[];
      json['CustomerTokens'].forEach((v) {
        customerTokens!.add(CustomerTokens.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SessionId'] = sessionId;
    data['CountryCode'] = countryCode;
    if (customerTokens != null) {
      data['CustomerTokens'] = customerTokens!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerTokens {
  String token = "";
  String cardNumber = "";
  String cardBrand = "";

  CustomerTokens({this.token = "", this.cardNumber = "", this.cardBrand = ""});

  CustomerTokens.fromJson(Map<String, dynamic> json) {
    token = json['Token'];
    cardNumber = json['CardNumber'];
    cardBrand = json['CardBrand'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Token'] = token;
    data['CardNumber'] = cardNumber;
    data['CardBrand'] = cardBrand;
    return data;
  }
}

class MFInitiateSessionRequest {
  String? customerIdentifier;
  bool? saveToken;
  bool? isRecurring;

  MFInitiateSessionRequest(
      {this.customerIdentifier, this.saveToken, this.isRecurring});

  MFInitiateSessionRequest.fromJson(Map<String, dynamic> json) {
    customerIdentifier = json['CustomerIdentifier'];
    saveToken = json['SaveToken'];
    isRecurring = json['IsRecurring'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomerIdentifier'] = customerIdentifier;
    data['SaveToken'] = saveToken;
    data['IsRecurring'] = isRecurring;
    return data;
  }
}

class MFUpdateSessionRequest {
  final String sessionId;
  final String token;
  final String tokenType; // TokenType: googlepay, mftoken
  final String? securityCode;

  MFUpdateSessionRequest({
    required this.sessionId,
    required this.token,
    required this.tokenType,
    this.securityCode,
  });

  factory MFUpdateSessionRequest.fromJson(Map<String, dynamic> json) {
    return MFUpdateSessionRequest(
      sessionId: json["SessionId"] as String,
      token: json["Token"] as String,
      tokenType: json["TokenType"] as String,
      securityCode: json["SecurityCode"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "SessionId": sessionId,
        "Token": token,
        "TokenType": tokenType,
        if (securityCode != null) "SecurityCode": securityCode,
      };
}

class MFUpdateSessionResponse {
  final String sessionId;
  final String countryCode;

  MFUpdateSessionResponse({
    required this.sessionId,
    required this.countryCode,
  });

  factory MFUpdateSessionResponse.fromJson(Map<String, dynamic> json) {
    return MFUpdateSessionResponse(
      sessionId: json["SessionId"] as String,
      countryCode: json["CountryCode"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        "SessionId": sessionId,
        "CountryCode": countryCode,
      };
}

class MFCallbackResponse {
  String? cardBrand;
  String? first8Digits;

  MFCallbackResponse({this.cardBrand, this.first8Digits});

  MFCallbackResponse.fromJson(Map<String, dynamic> json) {
    cardBrand = json['CardBrand'];
    first8Digits = json['First8Digits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CardBrand'] = cardBrand;
    data['First8Digits'] = first8Digits;
    return data;
  }
}

class MFExecutePaymentResponse {
  int? invoiceId;
  bool? isDirectPayment;
  String? paymentURL;
  String? customerReference;
  String? userDefinedField;
  String? recurringId;

  MFExecutePaymentResponse(
      {this.invoiceId,
      this.isDirectPayment,
      this.paymentURL,
      this.customerReference,
      this.userDefinedField,
      this.recurringId});

  MFExecutePaymentResponse.fromJson(Map<String, dynamic> json) {
    invoiceId = json['InvoiceId'];
    isDirectPayment = json['IsDirectPayment'];
    paymentURL = json['PaymentURL'];
    customerReference = json['CustomerReference'];
    userDefinedField = json['UserDefinedField'];
    recurringId = json['RecurringId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceId'] = invoiceId;
    data['IsDirectPayment'] = isDirectPayment;
    data['PaymentURL'] = paymentURL;
    data['CustomerReference'] = customerReference;
    data['UserDefinedField'] = userDefinedField;
    data['RecurringId'] = recurringId;
    return data;
  }
}

class MFPaymentWithSavedTokenRequest {
  MFExecutePaymentRequest? executePaymentRequest;
  String? token;
  String? securityCode;

  MFPaymentWithSavedTokenRequest(
      {this.executePaymentRequest, this.token, this.securityCode});

  MFPaymentWithSavedTokenRequest.fromJson(Map<String, dynamic> json) {
    executePaymentRequest =
        MFExecutePaymentRequest.fromJson(json['ExecutePaymentRequest']);
    token = json['Token'];
    securityCode = json['SecurityCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ExecutePaymentRequest'] = executePaymentRequest!.toJson();
    data['Token'] = token;
    data['SecurityCode'] = securityCode;
    return data;
  }
}

class MFExecutePaymentRequest {
  int? paymentMethodId;
  String? sessionId;
  MFRecurringModel? recurringModel;
  String? customerName;
  String? displayCurrencyIso;
  String? mobileCountryCode;
  String? customerMobile;
  String? customerEmail;
  num? invoiceValue;
  String? language;
  String? customerReference;
  String? customerCivilId;
  String? userDefinedField;
  MFCustomerAddres? customerAddress;
  String? expiryDate;
  List<MFInvoiceItem>? invoiceItems;
  // int? shippingMethod;
  // MFShippingConsignee? shippingConsignee;
  List<MFSupplier>? suppliers;
  ProcessingDetails? processingDetails;

  MFExecutePaymentRequest(
      {this.paymentMethodId,
      this.sessionId,
      this.recurringModel,
      this.customerName,
      this.displayCurrencyIso,
      this.mobileCountryCode,
      this.customerMobile,
      this.customerEmail,
      this.invoiceValue,
      this.language,
      this.customerReference,
      this.customerCivilId,
      this.userDefinedField,
      this.customerAddress,
      this.expiryDate,
      this.invoiceItems,
      // this.shippingMethod,
      // this.shippingConsignee,
      this.suppliers,
      this.processingDetails});

  MFExecutePaymentRequest.fromJson(Map<String, dynamic> json) {
    paymentMethodId = json['PaymentMethodId'];
    sessionId = json['SessionId'];
    recurringModel = json['RecurringModel'] != null
        ? MFRecurringModel.fromJson(json['RecurringModel'])
        : null;
    customerName = json['CustomerName'];
    displayCurrencyIso = json['DisplayCurrencyIso'];
    mobileCountryCode = json['MobileCountryCode'];
    customerMobile = json['CustomerMobile'];
    customerEmail = json['CustomerEmail'];
    invoiceValue = json['InvoiceValue'];
    language = json['Language'];
    customerReference = json['CustomerReference'];
    customerCivilId = json['CustomerCivilId'];
    userDefinedField = json['UserDefinedField'];
    customerAddress = json['CustomerAddress'] != null
        ? MFCustomerAddres.fromJson(json['CustomerAddress'])
        : null;
    expiryDate = json['ExpiryDate'];
    if (json['InvoiceItems'] != null) {
      invoiceItems = <MFInvoiceItem>[];
      json['InvoiceItems'].forEach((v) {
        invoiceItems!.add(MFInvoiceItem.fromJson(v));
      });
    }
    // shippingMethod = json['ShippingMethod'];
    // shippingConsignee = json['ShippingConsignee'] != null
    //     ? MFShippingConsignee.fromJson(json['ShippingConsignee'])
    //     : null;
    if (json['Suppliers'] != null) {
      suppliers = <MFSupplier>[];
      json['Suppliers'].forEach((v) {
        suppliers!.add(MFSupplier.fromJson(v));
      });
    }
    processingDetails = json['ProcessingDetails'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PaymentMethodId'] = paymentMethodId;
    data['SessionId'] = sessionId;
    if (recurringModel != null) {
      data['RecurringModel'] = recurringModel!.toJson();
    }
    data['CustomerName'] = customerName;
    data['DisplayCurrencyIso'] = displayCurrencyIso;
    data['MobileCountryCode'] = mobileCountryCode;
    data['CustomerMobile'] = customerMobile;
    data['CustomerEmail'] = customerEmail;
    data['InvoiceValue'] = invoiceValue;
    data['Language'] = language;
    data['CustomerReference'] = customerReference;
    data['CustomerCivilId'] = customerCivilId;
    data['UserDefinedField'] = userDefinedField;
    if (customerAddress != null) {
      data['CustomerAddress'] = customerAddress!.toJson();
    }
    data['ExpiryDate'] = expiryDate;
    if (invoiceItems != null) {
      data['InvoiceItems'] = invoiceItems!.map((v) => v.toJson()).toList();
    }
    // data['ShippingMethod'] = shippingMethod;
    // if (shippingConsignee != null) {
    //   data['ShippingConsignee'] = shippingConsignee!.toJson();
    // }
    if (suppliers != null) {
      data['Suppliers'] = suppliers!.map((v) => v.toJson()).toList();
    }
    if (processingDetails != null) {
      data['ProcessingDetails'] = processingDetails!.toJson();
    }
    return data;
  }
}

class ProcessingDetails {
  bool? autoCapture;

  ProcessingDetails({this.autoCapture});

  ProcessingDetails.fromJson(Map<String, dynamic> json) {
    autoCapture = json['AutoCapture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AutoCapture'] = autoCapture;
    return data;
  }
}

class MFRecurringModel {
  String? recurringType;
  int? intervalDays;
  int? iteration;
  int? retryCount;

  MFRecurringModel(
      {this.recurringType, this.intervalDays, this.iteration, this.retryCount});

  MFRecurringModel.fromJson(Map<String, dynamic> json) {
    recurringType = json['RecurringType'];
    intervalDays = json['IntervalDays'];
    iteration = json['Iteration'];
    retryCount = json['RetryCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecurringType'] = recurringType;
    data['IntervalDays'] = intervalDays;
    data['Iteration'] = iteration;
    data['RetryCount'] = retryCount;
    return data;
  }
}

class MFDirectPaymentRequest {
  MFExecutePaymentRequest? executePaymentRequest;
  MFCard? card;
  String? token;
  bool? saveToken;
  bool? bypass3DS;
  MFDirectPaymentRequest(
      {required this.executePaymentRequest,
      required this.card,
      required this.token,
      this.saveToken,
      this.bypass3DS});

  MFDirectPaymentRequest.fromJson(Map<String, dynamic> json) {
    executePaymentRequest =
        MFExecutePaymentRequest.fromJson(json['executePaymentRequest']);
    card = MFCard.fromJson(json['card']);
    token = json['token'];
    saveToken = json['saveToken'];
    bypass3DS = json['bypass3DS'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['executePaymentRequest'] = executePaymentRequest!.toJson();
    if (card != null) {
      data['card'] = card!.toJson();
    }
    data['token'] = token;
    data['saveToken'] = saveToken;
    data['bypass3DS'] = bypass3DS;
    return data;
  }
}

class MFDirectPaymentResponse {
  MFGetPaymentStatusResponse? mfPaymentStatusResponse =
      MFGetPaymentStatusResponse();
  DirectPaymentResponse? cardInfoResponse = DirectPaymentResponse();

  MFDirectPaymentResponse.fromJson(Map<String, dynamic> json) {
    mfPaymentStatusResponse = json['mfPaymentStatusResponse'] != null
        ? MFGetPaymentStatusResponse.fromJson(json['mfPaymentStatusResponse'])
        : null;
    cardInfoResponse = json['cardInfoResponse'] != null
        ? DirectPaymentResponse.fromJson(json['cardInfoResponse'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mfPaymentStatusResponse != null) {
      data['mfPaymentStatusResponse'] = mfPaymentStatusResponse!.toJson();
    }
    if (cardInfoResponse != null) {
      data['cardInfoResponse'] = cardInfoResponse!.toJson();
    }
    return data;
  }
}

class DirectPaymentResponse {
  String? status;
  String? errorMessage;
  String? paymentId;
  String? token;
  String? recurringId;
  String? paymentURL;
  MFCardInfo? cardInfo;

  DirectPaymentResponse(
      {this.status,
      this.errorMessage,
      this.paymentId,
      this.token,
      this.recurringId,
      this.paymentURL,
      this.cardInfo});

  DirectPaymentResponse.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    errorMessage = json['ErrorMessage'];
    paymentId = json['PaymentId'];
    token = json['Token'];
    recurringId = json['RecurringId'];
    paymentURL = json['PaymentURL'];
    cardInfo =
        json['CardInfo'] != null ? MFCardInfo.fromJson(json['CardInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['ErrorMessage'] = errorMessage;
    data['PaymentId'] = paymentId;
    data['Token'] = token;
    data['RecurringId'] = recurringId;
    data['PaymentURL'] = paymentURL;
    if (cardInfo != null) {
      data['CardInfo'] = cardInfo!.toJson();
    }
    return data;
  }
}

class MFCardInfo {
  String? number;
  String? expiryMonth;
  String? expiryYear;
  String? brand;
  String? issuer;

  MFCardInfo(
      {this.number,
      this.expiryMonth,
      this.expiryYear,
      this.brand,
      this.issuer});

  MFCardInfo.fromJson(Map<String, dynamic> json) {
    number = json['Number'];
    expiryMonth = json['ExpiryMonth'];
    expiryYear = json['ExpiryYear'];
    brand = json['Brand'];
    issuer = json['Issuer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Number'] = number;
    data['ExpiryMonth'] = expiryMonth;
    data['ExpiryYear'] = expiryYear;
    data['Brand'] = brand;
    data['Issuer'] = issuer;
    return data;
  }
}

class MFDirectPaymentModel {
  String? paymentType;
  bool? saveToken;
  MFCard? card;
  String? token;
  bool? bypass3DS;

  MFDirectPaymentModel(
      {this.paymentType,
      this.saveToken,
      this.card,
      this.token,
      this.bypass3DS});

  MFDirectPaymentModel.fromJson(Map<String, dynamic> json) {
    paymentType = json['PaymentType'];
    saveToken = json['SaveToken'];
    card = json['Card'] != null ? MFCard.fromJson(json['Card']) : null;
    token = json['Token'];
    bypass3DS = json['Bypass3DS'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PaymentType'] = paymentType;
    data['SaveToken'] = saveToken;
    if (card != null) {
      data['Card'] = card!.toJson();
    }
    data['Token'] = token;
    data['Bypass3DS'] = bypass3DS;
    return data;
  }
}

class MFCard {
  String? cardHolderName;
  String? number;
  String? expiryMonth;
  String? expiryYear;
  String? securityCode;
  MFCard(
      {required this.cardHolderName,
      required this.number,
      required this.expiryMonth,
      required this.expiryYear,
      required this.securityCode});

  MFCard.fromJson(Map<String, dynamic> json) {
    cardHolderName = json['cardHolderName'];
    number = json['number'];
    expiryMonth = json['expiryMonth'];
    expiryYear = json['expiryYear'];
    securityCode = json['securityCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cardHolderName'] = cardHolderName;
    data['number'] = number;
    data['expiryMonth'] = expiryMonth;
    data['expiryYear'] = expiryYear;
    data['securityCode'] = securityCode;
    return data;
  }
}

class MFGetPaymentStatusResponse {
  int? invoiceId;
  String? invoiceStatus;
  String? invoiceReference;
  String? customerReference;
  String? createdDate;
  String? expiryDate;
  String? expiryTime;
  num? invoiceValue;
  String? comments;
  String? customerName;
  String? customerMobile;
  String? customerEmail;
  String? userDefinedField;
  String? invoiceDisplayValue;
  num? dueDeposit;
  String? depositStatus;
  String? recurringId;
  List<MFInvoiceItem>? invoiceItems;
  List<MFInvoiceTransaction>? invoiceTransactions;
  List<MFSupplier>? suppliers;

  MFGetPaymentStatusResponse(
      {this.invoiceId,
      this.invoiceStatus,
      this.invoiceReference,
      this.customerReference,
      this.createdDate,
      this.expiryDate,
      this.expiryTime,
      this.invoiceValue,
      this.comments,
      this.customerName,
      this.customerMobile,
      this.customerEmail,
      this.userDefinedField,
      this.invoiceDisplayValue,
      this.dueDeposit,
      this.depositStatus,
      this.recurringId,
      this.invoiceItems,
      this.invoiceTransactions,
      this.suppliers});

  MFGetPaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    invoiceId = (json['InvoiceId'] as num?)?.toInt();
    invoiceStatus = json['InvoiceStatus'];
    invoiceReference = json['InvoiceReference'];
    customerReference = json['CustomerReference'];
    createdDate = json['CreatedDate'];
    expiryDate = json['ExpiryDate'];
    expiryTime = json['ExpiryTime'];
    invoiceValue = json['InvoiceValue'];
    comments = json['Comments'];
    customerName = json['CustomerName'];
    customerMobile = json['CustomerMobile'];
    customerEmail = json['CustomerEmail'];
    userDefinedField = json['UserDefinedField'];
    invoiceDisplayValue = json['InvoiceDisplayValue'];
    dueDeposit = json['DueDeposit'];
    recurringId = json['RecurringId'];
    depositStatus = json['DepositStatus'];
    if (json['InvoiceItems'] != null) {
      invoiceItems = <MFInvoiceItem>[];
      json['InvoiceItems'].forEach((v) {
        invoiceItems!.add(MFInvoiceItem.fromJson(v));
      });
    }
    if (json['InvoiceTransactions'] != null) {
      invoiceTransactions = <MFInvoiceTransaction>[];
      json['InvoiceTransactions'].forEach((v) {
        invoiceTransactions!.add(MFInvoiceTransaction.fromJson(v));
      });
    }
    if (json['Suppliers'] != null) {
      suppliers = <MFSupplier>[];
      json['Suppliers'].forEach((v) {
        suppliers!.add(MFSupplier.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceId'] = invoiceId;
    data['InvoiceStatus'] = invoiceStatus;
    data['InvoiceReference'] = invoiceReference;
    data['CustomerReference'] = customerReference;
    data['CreatedDate'] = createdDate;
    data['ExpiryDate'] = expiryDate;
    data['ExpiryTime'] = expiryTime;
    data['InvoiceValue'] = invoiceValue;
    data['Comments'] = comments;
    data['CustomerName'] = customerName;
    data['CustomerMobile'] = customerMobile;
    data['CustomerEmail'] = customerEmail;
    data['UserDefinedField'] = userDefinedField;
    data['InvoiceDisplayValue'] = invoiceDisplayValue;
    data['DueDeposit'] = dueDeposit;
    data['DepositStatus'] = depositStatus;
    data['RecurringId'] = recurringId;
    if (invoiceItems != null) {
      data['InvoiceItems'] = invoiceItems!.map((v) => v.toJson()).toList();
    }
    if (invoiceTransactions != null) {
      data['InvoiceTransactions'] =
          invoiceTransactions!.map((v) => v.toJson()).toList();
    }
    if (suppliers != null) {
      data['Suppliers'] = suppliers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MFInvoiceTransaction {
  String? transactionDate;
  String? paymentGateway;
  String? referenceId;
  String? trackId;
  String? transactionId;
  String? paymentId;
  String? authorizationId;
  String? transactionStatus;
  String? transationValue;
  String? customerServiceCharge;
  String? totalServiceCharge;
  String? dueValue;
  String? paidCurrency;
  String? paidCurrencyValue;
  String? ipAddress;
  String? country;
  String? currency;
  String? error;
  String? cardNumber;
  String? errorCode;

  MFInvoiceTransaction(
      {this.transactionDate,
      this.paymentGateway,
      this.referenceId,
      this.trackId,
      this.transactionId,
      this.paymentId,
      this.authorizationId,
      this.transactionStatus,
      this.transationValue,
      this.customerServiceCharge,
      this.totalServiceCharge,
      this.dueValue,
      this.paidCurrency,
      this.paidCurrencyValue,
      this.ipAddress,
      this.country,
      this.currency,
      this.error,
      this.cardNumber,
      this.errorCode});

  MFInvoiceTransaction.fromJson(Map<String, dynamic> json) {
    transactionDate = json['TransactionDate'];
    paymentGateway = json['PaymentGateway'];
    referenceId = json['ReferenceId'];
    trackId = json['TrackId'];
    transactionId = json['TransactionId'];
    paymentId = json['PaymentId'];
    authorizationId = json['AuthorizationId'];
    transactionStatus = json['TransactionStatus'];
    transationValue = json['TransationValue'];
    customerServiceCharge = json['CustomerServiceCharge'];
    totalServiceCharge = json['TotalServiceCharge'];
    dueValue = json['DueValue'];
    paidCurrency = json['PaidCurrency'];
    paidCurrencyValue = json['PaidCurrencyValue'];
    ipAddress = json['IpAddress'];
    country = json['Country'];
    currency = json['Currency'];
    error = json['Error'];
    cardNumber = json['CardNumber'];
    errorCode = json['ErrorCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TransactionDate'] = transactionDate;
    data['PaymentGateway'] = paymentGateway;
    data['ReferenceId'] = referenceId;
    data['TrackId'] = trackId;
    data['TransactionId'] = transactionId;
    data['PaymentId'] = paymentId;
    data['AuthorizationId'] = authorizationId;
    data['TransactionStatus'] = transactionStatus;
    data['TransationValue'] = transationValue;
    data['CustomerServiceCharge'] = customerServiceCharge;
    data['TotalServiceCharge'] = totalServiceCharge;
    data['DueValue'] = dueValue;
    data['PaidCurrency'] = paidCurrency;
    data['PaidCurrencyValue'] = paidCurrencyValue;
    data['IpAddress'] = ipAddress;
    data['Country'] = country;
    data['Currency'] = currency;
    data['Error'] = error;
    data['CardNumber'] = cardNumber;
    data['ErrorCode'] = errorCode;
    return data;
  }
}

class MFGetPaymentStatusRequest {
  String? key;
  String? keyType;

  MFGetPaymentStatusRequest({this.key, this.keyType});

  MFGetPaymentStatusRequest.fromJson(Map<String, dynamic> json) {
    key = json['Key'];
    keyType = json['KeyType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Key'] = key;
    data['KeyType'] = keyType;
    return data;
  }
}

class MFGetRecurringPaymentResponse {
  List<MFRecurringPayment>? recurringPayment;

  MFGetRecurringPaymentResponse({this.recurringPayment});

  MFGetRecurringPaymentResponse.fromJson(Map<String, dynamic> json) {
    if (json['RecurringPayment'] != null) {
      recurringPayment = <MFRecurringPayment>[];
      json['RecurringPayment'].forEach((v) {
        recurringPayment!.add(MFRecurringPayment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (recurringPayment != null) {
      data['RecurringPayment'] =
          recurringPayment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MFRecurringPayment {
  String? recurringId;
  String? recurringStatus;
  String? creationDate;
  int? recurringValue;
  String? recurringType;
  int? intervalDays;
  int? executedTimes;
  String? lastPayDate;
  String? nextPayDate;
  bool? isActive;
  List<MFRecurringInvoice>? recurringInvoices;

  MFRecurringPayment(
      {this.recurringId,
      this.recurringStatus,
      this.creationDate,
      this.recurringValue,
      this.recurringType,
      this.intervalDays,
      this.executedTimes,
      this.lastPayDate,
      this.nextPayDate,
      this.isActive,
      this.recurringInvoices});

  MFRecurringPayment.fromJson(Map<String, dynamic> json) {
    recurringId = json['RecurringId'];
    recurringStatus = json['RecurringStatus'];
    creationDate = json['CreationDate'];
    recurringValue = json['RecurringValue'];
    recurringType = json['RecurringType'];
    intervalDays = json['IntervalDays'];
    executedTimes = json['ExecutedTimes'];
    lastPayDate = json['LastPayDate'];
    nextPayDate = json['NextPayDate'];
    isActive = json['IsActive'];
    if (json['RecurringInvoices'] != null) {
      recurringInvoices = <MFRecurringInvoice>[];
      json['RecurringInvoices'].forEach((v) {
        recurringInvoices!.add(MFRecurringInvoice.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecurringId'] = recurringId;
    data['RecurringStatus'] = recurringStatus;
    data['CreationDate'] = creationDate;
    data['RecurringValue'] = recurringValue;
    data['RecurringType'] = recurringType;
    data['IntervalDays'] = intervalDays;
    data['ExecutedTimes'] = executedTimes;
    data['LastPayDate'] = lastPayDate;
    data['NextPayDate'] = nextPayDate;
    data['IsActive'] = isActive;
    if (recurringInvoices != null) {
      data['RecurringInvoices'] =
          recurringInvoices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MFRecurringInvoice {
  int? invoiceId;
  String? customerReference;
  String? customerName;
  String? customerMobile;
  String? createdDate;
  String? invoiceStatus;

  MFRecurringInvoice(
      {this.invoiceId,
      this.customerReference,
      this.customerName,
      this.customerMobile,
      this.createdDate,
      this.invoiceStatus});

  MFRecurringInvoice.fromJson(Map<String, dynamic> json) {
    invoiceId = json['InvoiceId'];
    customerReference = json['CustomerReference'];
    customerName = json['CustomerName'];
    customerMobile = json['CustomerMobile'];
    createdDate = json['CreatedDate'];
    invoiceStatus = json['InvoiceStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['InvoiceId'] = invoiceId;
    data['CustomerReference'] = customerReference;
    data['CustomerName'] = customerName;
    data['CustomerMobile'] = customerMobile;
    data['CreatedDate'] = createdDate;
    data['InvoiceStatus'] = invoiceStatus;
    return data;
  }
}

class MFCardViewStyle {
  bool hideCardIcons = true;
  String direction = "ltr";
  num backgroundColor = getColorHexFromStr("#ffffff");
  int cardHeight = 230;
  MFCardViewInput? input = MFCardViewInput();
  MFCardViewLabel? label = MFCardViewLabel();
  MFCardViewError? error = MFCardViewError();
  MFSavedCardText? savedCardText = MFSavedCardText();

  MFCardViewStyle();

  MFCardViewStyle.fromJson(Map<String, dynamic> json) {
    hideCardIcons = json['hideCardIcons'];
    direction = json['direction'];
    cardHeight = json['cardHeight'];
    input =
        json['input'] != null ? MFCardViewInput.fromJson(json['input']) : null;
    label =
        json['label'] != null ? MFCardViewLabel.fromJson(json['label']) : null;
    error =
        json['error'] != null ? MFCardViewError.fromJson(json['error']) : null;
    savedCardText = json['savedCardText'] != null
        ? MFSavedCardText.fromJson(json['savedCardText'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hideCardIcons'] = hideCardIcons;
    data['direction'] = direction;
    data['cardHeight'] = cardHeight;
    data['backgroundColor'] = backgroundColor;
    if (input != null) {
      data['input'] = input!.toJson();
    }
    if (label != null) {
      data['label'] = label!.toJson();
    }
    if (error != null) {
      data['error'] = error!.toJson();
    }
    if (savedCardText != null) {
      data['savedCardText'] = savedCardText!.toJson();
    }
    return data;
  }
}

class MFSavedCardText {
  String? saveCardText = "Save card no. for future payments";
  String? addCardText = "Use Another Card";
  MFDeleteAlert? deleteAlertText = MFDeleteAlert();

  MFSavedCardText({this.saveCardText, this.addCardText, this.deleteAlertText});

  factory MFSavedCardText.fromJson(Map<String, dynamic> json) =>
      MFSavedCardText(
        saveCardText: json["saveCardText"] as String,
        addCardText: json["addCardText"] as String,
        deleteAlertText: MFDeleteAlert.fromJson(
            json["deleteAlertText"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "saveCardText": saveCardText,
        "addCardText": addCardText,
        "deleteAlertText": deleteAlertText?.toJson(),
      };
}

class MFDeleteAlert {
  String? title = "Delete Card";
  String? message = "Are you sure you want to remove this Card?";
  String? confirm = "Yes";
  String? cancel = "No";

  MFDeleteAlert({this.title, this.message, this.confirm, this.cancel});

  factory MFDeleteAlert.fromJson(Map<String, dynamic> json) => MFDeleteAlert(
        title: json["title"] as String,
        message: json["message"] as String,
        confirm: json["confirm"] as String,
        cancel: json["cancel"] as String,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "message": message,
        "confirm": confirm,
        "cancel": cancel,
      };
}

class MFCardViewInput {
  num? color = getColorHexFromStr("#000000");
  num? fontSize = 13;
  String? fontFamily = MFFontFamily.SansSerif;
  num? inputHeight = 32;
  num? inputMargin = 0;
  num? borderColor = getColorHexFromStr("#c7c7c7");
  num? borderWidth = 1;
  num? borderRadius = 8;
  MFBoxShadow? boxShadow = MFBoxShadow();
  MFCardViewPlaceHolder? placeHolder = MFCardViewPlaceHolder();

  MFCardViewInput();

  MFCardViewInput.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    fontSize = json['fontSize'];
    fontFamily = json['fontFamily'];
    inputHeight = json['inputHeight'];
    inputMargin = json['inputMargin'];
    borderColor = json['borderColor'];
    borderWidth = json['borderWidth'];
    borderRadius = json['borderRadius'];
    boxShadow = json['boxShadow'] != null
        ? MFBoxShadow.fromJson(json['boxShadow'])
        : null;
    placeHolder = json['placeHolder'] != null
        ? MFCardViewPlaceHolder.fromJson(json['placeHolder'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['fontSize'] = fontSize;
    data['fontFamily'] = fontFamily;
    data['inputHeight'] = inputHeight;
    data['inputMargin'] = inputMargin;
    data['borderColor'] = borderColor;
    data['borderWidth'] = borderWidth;
    data['borderRadius'] = borderRadius;
    if (boxShadow != null) {
      data['boxShadow'] = boxShadow!.toJson();
    }
    if (placeHolder != null) {
      data['placeHolder'] = placeHolder!.toJson();
    }
    return data;
  }
}

class MFCardViewPlaceHolder {
  String? holderName = 'Name On Card';
  String? cardNumber = 'Number';
  String? expiryDate = 'MM / YY';
  String? securityCode = 'CVV';

  MFCardViewPlaceHolder();

  MFCardViewPlaceHolder.fromJson(Map<String, dynamic> json) {
    holderName = json['holderName'];
    cardNumber = json['cardNumber'];
    expiryDate = json['expiryDate'];
    securityCode = json['securityCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['holderName'] = holderName;
    data['cardNumber'] = cardNumber;
    data['expiryDate'] = expiryDate;
    data['securityCode'] = securityCode;
    return data;
  }
}

class MFCardViewLabel {
  bool? display = true;
  num? color = getColorHexFromStr("#000000");
  num? fontSize = 13;
  String? fontWeight = MFFontWeight.Normal;
  String? fontFamily = MFFontFamily.SansSerif;
  MFCardViewText? text = MFCardViewText();

  MFCardViewLabel();

  MFCardViewLabel.fromJson(Map<String, dynamic> json) {
    display = json['display'];
    color = json['color'];
    fontSize = json['fontSize'];
    fontWeight = json['fontWeight'];
    fontFamily = json['fontFamily'];
    text = json['text'] != null ? MFCardViewText.fromJson(json['text']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['display'] = display;
    data['color'] = color;
    data['fontSize'] = fontSize;
    data['fontWeight'] = fontWeight;
    data['fontFamily'] = fontFamily;
    if (text != null) {
      data['text'] = text!.toJson();
    }
    return data;
  }
}

class MFCardViewText {
  String? holderName;
  String? cardNumber;
  String? expiryDate;
  String? securityCode;

  MFCardViewText(
      {this.holderName = 'Card Holder Name',
      this.cardNumber = 'Card Number',
      this.expiryDate = 'Expiry Date',
      this.securityCode = 'Security Code'});

  MFCardViewText.fromJson(Map<String, dynamic> json) {
    holderName = json['holderName'];
    cardNumber = json['cardNumber'];
    expiryDate = json['expiryDate'];
    securityCode = json['securityCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['holderName'] = holderName;
    data['cardNumber'] = cardNumber;
    data['expiryDate'] = expiryDate;
    data['securityCode'] = securityCode;
    return data;
  }
}

class MFCardViewError {
  num? borderColor = getColorHexFromStr("#ff3300");
  num? borderRadius = 8;
  MFBoxShadow? boxShadow = MFBoxShadow();

  MFCardViewError();

  MFCardViewError.fromJson(Map<String, dynamic> json) {
    borderColor = json['borderColor'];
    borderRadius = json['borderRadius'];
    boxShadow = json['boxShadow'] != null
        ? MFBoxShadow.fromJson(json['boxShadow'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['borderColor'] = borderColor;
    data['borderRadius'] = borderRadius;
    if (boxShadow != null) {
      data['boxShadow'] = boxShadow!.toJson();
    }
    return data;
  }
}

class MFBoxShadow {
  num? hOffset = 0;
  num? vOffset = 0;
  num? blur = 0;
  num? spread = 0;
  num? color = getColorHexFromStr("#ffffff");

  MFBoxShadow();

  MFBoxShadow.fromJson(Map<String, dynamic> json) {
    hOffset = json['hOffset'];
    vOffset = json['vOffset'];
    blur = json['blur'];
    spread = json['spread'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hOffset'] = hOffset;
    data['vOffset'] = vOffset;
    data['blur'] = blur;
    data['spread'] = spread;
    data['color'] = color;
    return data;
  }
}

class MFApplePayStyle {
  num height = 30;
  num borderRadius = 8;
  String buttonText = "Pay with";
  bool hideLoadingIndicator = false;
  String vendorName = "";

  MFApplePayStyle();

  MFApplePayStyle.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    borderRadius = json['borderRadius'];
    buttonText = json['buttonText'];
    hideLoadingIndicator = json['hideLoadingIndicator'];
    vendorName = json['vendorName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['borderRadius'] = borderRadius;
    data['buttonText'] = buttonText;
    data['hideLoadingIndicator'] = hideLoadingIndicator;
    data['vendorName'] = vendorName;
    return data;
  }
}

class MFError {
  String? code;
  String? message;
  MFError({this.code, this.message});
  MFError.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}

class MFGooglePayRequest {
  String? totalPrice;
  String? merchantId;
  String? merchantName;
  String? countryCode;
  String? currencyIso;

  MFGooglePayRequest({
    required this.totalPrice,
    required this.merchantId,
    required this.merchantName,
    required this.countryCode,
    required this.currencyIso,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalPrice'] = totalPrice;
    data['merchantId'] = merchantId;
    data['merchantName'] = merchantName;
    data['countryCode'] = countryCode;
    data['currencyIso'] = currencyIso;
    return data;
  }
}