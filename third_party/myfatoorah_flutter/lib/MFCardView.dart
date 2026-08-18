// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/MFConstants.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

interface class ICardViewProps {
  MFCardViewStyle? cardViewStyle;
}

abstract class IMFCardView {
  void load(MFInitiateSessionResponse initiateSessionResponse,
      Function(String bin)? onCardBinChanged,
      {bool showNFCReadCardIcon = false});
  Future<String> validate({String currency = ""});
  Future<MFGetPaymentStatusResponse> pay(MFExecutePaymentRequest request,
      String lang, Function(String invoiceId) onInvoiceCreated,
      {String currency = ""});
}

// ignore: must_be_immutable
class MFCardPaymentView extends StatefulWidget
    implements ICardViewProps, IMFCardView {
  MFCardPaymentView({
    super.key,
    this.cardViewStyle,
    this.onPlatformViewCreated,
  });

  final VoidCallback? onPlatformViewCreated;

  @override
  State<MFCardPaymentView> createState() => _MFCardPaymentView();

  @override
  late MFCardViewStyle? cardViewStyle;

  @override
  void load(MFInitiateSessionResponse initiateSessionResponse,
      Function(String bin)? onCardBinChanged,
      {bool showNFCReadCardIcon = false}) {
    MFSDK.load(initiateSessionResponse, showNFCReadCardIcon, onCardBinChanged);
  }

  @override
  Future<String> validate({String currency = ""}) async {
    return await MFSDK.validate(currency);
  }

  @override
  Future<MFGetPaymentStatusResponse> pay(MFExecutePaymentRequest request,
      String lang, Function(String invoiceId) onInvoiceCreated,
      {String currency = ""}) async {
    return await MFSDK.pay(request, lang, currency, onInvoiceCreated);
  }
}

class _MFCardPaymentView extends State<MFCardPaymentView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = MFConstants.MFCardViewModuleNAME;
    // Pass parameters to the platform side.
    Map<String, dynamic> creationParams = widget.cardViewStyle != null
        ? <String, dynamic>{
            "cardViewStyle": jsonEncode(widget.cardViewStyle?.toJson())
          }
        : <String, dynamic>{};

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener((id) {
                params.onPlatformViewCreated(id);
                widget.onPlatformViewCreated?.call();
              })
              ..create();
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (_) => widget.onPlatformViewCreated?.call(),
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}
