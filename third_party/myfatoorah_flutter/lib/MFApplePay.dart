// ignore_for_file: file_names

import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

abstract class IMFApplePay {
  Future<bool> setupApplePay(MFInitiateSessionResponse session,
      MFExecutePaymentRequest request, String lang,
      {String? merchantName});
  Future<MFCallbackResponse> openPaymentSheet();
  Future<MFGetPaymentStatusResponse> executeApplePayPayment(
      {MFExecutePaymentRequest? request,
      Function(String invoiceId)? onInvoiceCreated});
  updateAmount(double amount);
}

// ignore: non_constant_identifier_names
final MFApplepay = MFApplePay();

// ignore: must_be_immutable
class MFApplePay implements IMFApplePay {
  static final MFApplePay instance = MFApplePay._internal();
  MFApplePay._internal();

  factory MFApplePay() {
    return instance;
  }

  @override
  Future<bool> setupApplePay(MFInitiateSessionResponse session,
      MFExecutePaymentRequest request, String lang,
      {String? merchantName}) async {
    return await MFSDK.setupApplePay(session, request, lang, merchantName);
  }

  @override
  Future<MFCallbackResponse> openPaymentSheet() async {
    return await MFSDK.openPaymentSheet();
  }

  @override
  Future<MFGetPaymentStatusResponse> executeApplePayPayment(
      {MFExecutePaymentRequest? request,
      Function(String invoiceId)? onInvoiceCreated}) async {
    return await MFSDK.executeApplePayPayment(request, onInvoiceCreated);
  }

  @override
  updateAmount(double amount) {
    MFSDK.updateApplePayAmount(amount);
  }
}
