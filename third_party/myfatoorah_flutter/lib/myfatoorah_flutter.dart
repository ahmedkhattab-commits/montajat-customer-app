import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/MFModels.dart';
// ignore: unused_import
import 'package:myfatoorah_flutter/MFEnums.dart';
import 'package:myfatoorah_flutter/MFUtils.dart';
import 'MFConstants.dart';
export 'MFCardView.dart';
export 'MFApplePayButton.dart';
export 'MFGooglePayButton.dart';
export 'MFApplePay.dart';
export 'MFModels.dart';
export 'MFEnums.dart';

class _MFSDKHelperCodec extends StandardMessageCodec {
  const _MFSDKHelperCodec();

  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is MFPaymentWithSavedTokenRequest) {
      buffer.putUint8(BufferType.MFPaymentWithSavedTokenRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFDirectPaymentRequest) {
      buffer.putUint8(BufferType.MFDirectPaymentRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFExecutePaymentRequest) {
      buffer.putUint8(BufferType.MFExecutePaymentRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFGetPaymentStatusRequest) {
      buffer.putUint8(BufferType.MFGetPaymentStatusRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFInitiatePaymentRequest) {
      buffer.putUint8(BufferType.MFInitiatePaymentRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFInitiateSessionRequest) {
      buffer.putUint8(BufferType.MFInitiateSessionRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFUpdateSessionRequest) {
      buffer.putUint8(BufferType.MFUpdateSessionRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFSendPaymentRequest) {
      buffer.putUint8(BufferType.MFSendPaymentRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFInitiateSessionResponse) {
      buffer.putUint8(BufferType.MFInitiateSessionResponse);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFGooglePayRequest) {
      buffer.putUint8(BufferType.MFGooglePayRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case BufferType.MFDirectPaymentResponse:
        return MFDirectPaymentResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFGetPaymentStatusResponse:
        return MFGetPaymentStatusResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFInitiatePaymentResponse:
        return MFInitiatePaymentResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFInitiateSessionResponse:
        return MFInitiateSessionResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFUpdateSessionResponse:
        return MFUpdateSessionResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFSendPaymentResponse:
        return MFSendPaymentResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFCallbackResponse:
        return MFCallbackResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFError:
        return MFError.fromJson(jsonDecode(readValue(buffer)!.toString()));
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

// ignore: non_constant_identifier_names
final MFSDK = MyFatoorahFlutter();

class MyFatoorahFlutter {
  static final MyFatoorahFlutter instance = MyFatoorahFlutter._internal();
  MyFatoorahFlutter._internal();

  factory MyFatoorahFlutter({BinaryMessenger? binaryMessenger}) {
    instance._binaryMessenger = binaryMessenger;
    return instance;
  }

  BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _MFSDKHelperCodec();
  static const EventChannel eventChannel =
      EventChannel(MFConstants.MFEventChannelName);

  Future<MFInitiatePaymentResponse> initiatePayment(
      MFInitiatePaymentRequest initiatePaymentRequest, String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.initiatePayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[initiatePaymentRequest, lang]) as List<Object?>?;
    return modelParser<MFInitiatePaymentResponse>(replyList);
  }

  Future<void> init(String apiKey, String country, String environment) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.loadConfig, codec,
        binaryMessenger: _binaryMessenger);
    await channel.send(<Object?>[apiKey, country, environment]);
  }

  setUpActionBar(
      {String toolBarTitle = "",
      String toolBarTitleColor = "",
      String toolBarBackgroundColor = "",
      bool isShowToolBar = false}) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.setUpActionBar, codec,
        binaryMessenger: _binaryMessenger);
    channel.send(<Object?>[
      toolBarTitle,
      getColorHexFromStr(toolBarTitleColor),
      getColorHexFromStr(toolBarBackgroundColor),
      isShowToolBar
    ]);
  }

  Future<MFSendPaymentResponse> sendPayment(
      MFSendPaymentRequest sendPaymentRequest, String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.sendPayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[sendPaymentRequest, lang]) as List<Object?>?;
    return modelParser<MFSendPaymentResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> getPaymentStatus(
      MFGetPaymentStatusRequest getPaymentStatusRequest, String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.getPaymentStatus, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[getPaymentStatusRequest, lang]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> executePayment(
      MFExecutePaymentRequest executePaymentRequest,
      String lang,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.executePayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[executePaymentRequest, lang]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> executePaymentWithGooglePay(
      MFExecutePaymentRequest executePaymentRequest,
      String lang,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.executePaymentWithGooglePay, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[executePaymentRequest, lang]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> executePaymentWithSavedToken(
      MFPaymentWithSavedTokenRequest savedTokenRequest,
      String lang,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.executePaymentWithSavedToken, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[savedTokenRequest, lang]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<MFDirectPaymentResponse> executeDirectPayment(
      MFDirectPaymentRequest directPaymentRequest,
      String lang,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.executeDirectPayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[directPaymentRequest, lang]) as List<Object?>?;
    return modelParser<MFDirectPaymentResponse>(replyList);
  }

  Future<bool> cancelToken(String token, String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.cancelToken, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[token, lang]) as List<Object?>?;
    return modelParser<bool>(replyList);
  }

  Future<bool> cancelRecurringPayment(String recurringId, String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.cancelRecurringPayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[recurringId, lang]) as List<Object?>?;
    return modelParser<bool>(replyList);
  }

  Future<MFInitiateSessionResponse> initSession(
      MFInitiateSessionRequest initiateSessionRequest, String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.initSession, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[initiateSessionRequest, lang]) as List<Object?>?;
    return modelParser<MFInitiateSessionResponse>(replyList);
  }

  load(MFInitiateSessionResponse initiateSessionResponse,
      bool showNFCReadCardIcon, Function(String bin)? onCardBinChanged) async {
    if (onCardBinChanged != null) {
      eventChannel.receiveBroadcastStream().listen((bin) {
        onCardBinChanged(bin);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.load, codec,
        binaryMessenger: _binaryMessenger);
    channel.send(<Object?>[initiateSessionResponse, showNFCReadCardIcon])
        as Future<Object?>?;
  }

  Future<MFInitiateSessionResponse> initiateSession(
      MFInitiateSessionRequest initiateSessionRequest,
      Function(String bin)? onCardBinChanged,
      {bool showNFCReadCardIcon = false}) async {
    if (onCardBinChanged != null) {
      eventChannel.receiveBroadcastStream().listen((bin) {
        onCardBinChanged(bin);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.initiateSession, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
            .send(<Object?>[initiateSessionRequest, showNFCReadCardIcon])
        as List<Object?>?;
    return modelParser<MFInitiateSessionResponse>(replyList);
  }

  Future<MFUpdateSessionResponse> updateSession(
      MFUpdateSessionRequest updateSessionRequest) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.updateSession, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[updateSessionRequest]) as List<Object?>?;
    return modelParser<MFUpdateSessionResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> pay(
      MFExecutePaymentRequest executePaymentRequest,
      String lang,
      String currency,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.pay, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[executePaymentRequest, lang, currency])
            as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<String> validate(String currency) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.validate, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send([currency]) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  /// @deprecated Use MFSDK.gPay APIs instead. This method uses deprecated MFGooglePayHelper.
  Future<MFGetPaymentStatusResponse> setupGooglePayHelper(
      String sessionId,
      MFGooglePayRequest googlePayRequest,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.googlePayPayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[sessionId, googlePayRequest]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  /// @deprecated Use MFSDK.gPay APIs instead. This method uses deprecated MFGooglePayTokenHelper.
  Future<String> setupGooglePayTokenHelper(
      MFGooglePayRequest googlePayRequest) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.googlePayToken, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[googlePayRequest]) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  Future<MFGetPaymentStatusResponse> applePayPayment(
      MFExecutePaymentRequest executePaymentRequest,
      String lang,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.applePayPayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[executePaymentRequest, lang]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> loadApplePay(
      MFInitiateSessionResponse session,
      MFExecutePaymentRequest executePaymentRequest,
      String lang,
      [Function(String message)? onSessionCreated]) async {
    if (onSessionCreated != null) {
      eventChannel.receiveBroadcastStream().listen((message) {
        onSessionCreated(message);
      });
    }
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.applePayLoad, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[session, executePaymentRequest, lang])
            as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<MFCallbackResponse> displayApplePayButton(
      MFInitiateSessionResponse session,
      MFExecutePaymentRequest executePaymentRequest,
      String lang) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.displayApplePayButton, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[session, executePaymentRequest, lang])
            as List<Object?>?;
    return modelParser<MFCallbackResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> executeApplePayButton(
      MFExecutePaymentRequest? executePaymentRequest,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.executeApplePayButton, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[executePaymentRequest]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  Future<bool> setupApplePay(
      MFInitiateSessionResponse session,
      MFExecutePaymentRequest executePaymentRequest,
      String lang,
      String? merchantName) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.setupApplePay, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
            .send(<Object?>[session, executePaymentRequest, lang, merchantName])
        as List<Object?>?;
    return modelParser<bool>(replyList);
  }

  applePayLoaded(Function(String result) onLoad) async {
    eventChannel.receiveBroadcastStream().listen((invoiceId) {
      onLoad(invoiceId);
    });
  }

  Future<MFCallbackResponse> openPaymentSheet() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.openPaymentSheet, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[]) as List<Object?>?;
    return modelParser<MFCallbackResponse>(replyList);
  }

  Future<MFGetPaymentStatusResponse> executeApplePayPayment(
      MFExecutePaymentRequest? executePaymentRequest,
      Function(String invoiceId)? onInvoiceCreated) async {
    if (onInvoiceCreated != null) {
      eventChannel.receiveBroadcastStream().listen((invoiceId) {
        onInvoiceCreated(invoiceId);
      });
    }

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.executeApplePayPayment, codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[executePaymentRequest]) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }

  updateApplePayAmount(double amount) {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        MFConstants.channelName.updateApplePayAmount, codec,
        binaryMessenger: _binaryMessenger);
    channel.send(<Object?>[amount]);
  }
}
