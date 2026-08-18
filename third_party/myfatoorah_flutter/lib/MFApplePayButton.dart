// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/MFConstants.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

interface class IApplePayProps {
  MFApplePayStyle? applePayStyle;
}

abstract class IMFApplePayButton {
  Future<MFGetPaymentStatusResponse> applePayPayment(MFExecutePaymentRequest request,
      String lang, Function(String invoiceId) onInvoiceCreated);
  Future<MFGetPaymentStatusResponse> load(MFInitiateSessionResponse session, MFExecutePaymentRequest request,
      String lang, [Function(String message)? onSessionCreated]);
  Future<MFCallbackResponse> displayApplePayButton(MFInitiateSessionResponse session, MFExecutePaymentRequest request,
      String lang);
  Future<MFGetPaymentStatusResponse> executeApplePayButton(MFExecutePaymentRequest? request,
      Function(String invoiceId) onInvoiceCreated);
}

// ignore: must_be_immutable
class MFApplePayButton extends StatefulWidget 
    implements IApplePayProps, IMFApplePayButton {
  MFApplePayButton({super.key, this.applePayStyle});

  @override
  State<MFApplePayButton> createState() => _MFApplePayButton();

  @override
  late MFApplePayStyle? applePayStyle;

  @override
  Future<MFGetPaymentStatusResponse> applePayPayment(MFExecutePaymentRequest request,
      String lang, Function(String invoiceId) onInvoiceCreated) async {
    return await MFSDK.applePayPayment(request, lang, onInvoiceCreated);
  }

    @override
  Future<MFGetPaymentStatusResponse> load(MFInitiateSessionResponse session, MFExecutePaymentRequest request,
      String lang, [Function(String message)? onSessionCreated]) async {
    return await MFSDK.loadApplePay(session, request, lang, onSessionCreated);
  }

  @override
  Future<MFCallbackResponse> displayApplePayButton(MFInitiateSessionResponse session, MFExecutePaymentRequest request,
      String lang) async {
    return await MFSDK.displayApplePayButton(session, request, lang);
  }

  @override
  Future<MFGetPaymentStatusResponse> executeApplePayButton(MFExecutePaymentRequest? request,
      Function(String invoiceId) onInvoiceCreated) async {
    return await MFSDK.executeApplePayButton(request, onInvoiceCreated);
  }
}

class _MFApplePayButton extends State<MFApplePayButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = MFConstants.MFApplePayModuleNAME;
    Map<String, dynamic> creationParams = widget.applePayStyle != null
        ? <String, dynamic>{
            "applePayStyle": jsonEncode(widget.applePayStyle?.toJson())
          }
        : <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
