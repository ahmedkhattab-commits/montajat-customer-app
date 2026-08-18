// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/MFConstants.dart';
import 'package:myfatoorah_flutter/MFModels.dart';
import 'package:myfatoorah_flutter/MFUtils.dart';

class _MFGPayHelperCodec extends StandardMessageCodec {
  const _MFGPayHelperCodec();

  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is MFExecutePaymentRequest) {
      buffer.putUint8(BufferType.MFExecutePaymentRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFGetPaymentStatusRequest) {
      buffer.putUint8(BufferType.MFGetPaymentStatusRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFInitiateSessionRequest) {
      buffer.putUint8(BufferType.MFInitiateSessionRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFInitiateSessionResponse) {
      buffer.putUint8(BufferType.MFInitiateSessionResponse);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFUpdateSessionRequest) {
      buffer.putUint8(BufferType.MFUpdateSessionRequest);
      writeValue(buffer, jsonEncode(value.toJson()));
    } else if (value is MFUpdateSessionResponse) {
      buffer.putUint8(BufferType.MFUpdateSessionResponse);
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
      case BufferType.MFGetPaymentStatusResponse:
        return MFGetPaymentStatusResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFInitiateSessionResponse:
        return MFInitiateSessionResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFUpdateSessionResponse:
        return MFUpdateSessionResponse.fromJson(
            jsonDecode(readValue(buffer)!.toString()));
      case BufferType.MFError:
        return MFError.fromJson(jsonDecode(readValue(buffer)!.toString()));
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

// ignore: non_constant_identifier_names
final MFGooglePay = MFGPayFlutter();

class MFGPayFlutter {
  MFGPayFlutter({
    BinaryMessenger? binaryMessenger,
  }) : _binaryMessenger = binaryMessenger;

  static const MessageCodec<Object?> codec = _MFGPayHelperCodec();

  /// Timeout duration for payment setup operations
  static const Duration paymentSetupTimeout = Duration(seconds: 30);

  /// Timeout duration for payment execution operations
  static const Duration paymentExecutionTimeout = Duration(seconds: 60);

  /// Timeout duration for quick operations (availability, updates, etc.)
  static const Duration quickOperationTimeout = Duration(seconds: 10);

  BinaryMessenger? _binaryMessenger;

  static const EventChannel _googlePayEventChannel =
      EventChannel(MFConstants.MFEventChannelGPayName);

  StreamSubscription<dynamic>? _googlePayEventSubscription;
  Function(String)? _onInvoiceCreated;
  Function(String, MFGetPaymentStatusResponse)? _onExecutePaymentSuccess;
  Function(String)? _onSessionUpdated;
  Function(String)? _onReceivedToken;
  Function(MFError)? _onError;

  void updateBinaryMessenger(BinaryMessenger? binaryMessenger) {
    _binaryMessenger = binaryMessenger;
  }

  void dispose() {
    _googlePayEventSubscription?.cancel();
    _googlePayEventSubscription = null;
    _onInvoiceCreated = null;
    _onExecutePaymentSuccess = null;
    _onSessionUpdated = null;
    _onReceivedToken = null;
    _onError = null;
  }

  /// Clear the current Google Pay setup and clean up resources
  /// Call this when switching between payment modes to prevent callback leaks
  void clearCurrentSetup() {
    _googlePayEventSubscription?.cancel();
    _googlePayEventSubscription = null;
    _onInvoiceCreated = null;
    _onExecutePaymentSuccess = null;
    _onSessionUpdated = null;
    _onReceivedToken = null;
    _onError = null;
  }

  dynamic _normalizePlatformValue(dynamic value) {
    if (value is Map) {
      return value.map((key, item) =>
          MapEntry(key.toString(), _normalizePlatformValue(item)));
    }

    if (value is List) {
      return value.map(_normalizePlatformValue).toList();
    }

    return value;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is! Map) return null;
    return _normalizePlatformValue(value) as Map<String, dynamic>;
  }

  void _handleGooglePayEvent(dynamic event) {
    final eventData = _asMap(event);
    if (eventData == null) return;

    final eventType = eventData['eventType'] as String?;

    switch (eventType) {
      case 'onInvoiceCreated':
        final invoiceId = eventData['invoiceId']?.toString();
        if (_onInvoiceCreated != null && invoiceId != null) {
          _onInvoiceCreated!(invoiceId);
        }
        break;

      case 'onExecutePaymentSuccess':
        final paymentStatusData = _asMap(eventData['paymentStatus']);
        if (_onExecutePaymentSuccess != null && paymentStatusData != null) {
          final paymentStatus =
              MFGetPaymentStatusResponse.fromJson(paymentStatusData);
          final invoiceId = eventData['invoiceId']?.toString() ??
              paymentStatus.invoiceId?.toString() ??
              '';
          _onExecutePaymentSuccess!(invoiceId, paymentStatus);
        }
        break;

      case 'onSessionUpdated':
        final sessionId = eventData['sessionId']?.toString();
        if (_onSessionUpdated != null && sessionId != null) {
          _onSessionUpdated!(sessionId);
        }
        break;

      case 'onReceivedToken':
        final token = eventData['token']?.toString();
        if (_onReceivedToken != null && token != null) {
          _onReceivedToken!(token);
        }
        break;

      case 'onError':
        final errorData = _asMap(eventData['error']);
        if (_onError != null && errorData != null) {
          final error = MFError.fromJson(errorData);
          _onError!(error);
        }
        break;
    }
  }

  void _handleGooglePayStreamError(Object error) {
    if (_onError == null) return;

    if (error is PlatformException) {
      final details = _asMap(error.details);
      final embeddedError = _asMap(details?['error']);
      final code = embeddedError?['code']?.toString() ?? error.code;
      final message =
          embeddedError?['message']?.toString() ?? error.message ?? 'Unknown';
      _onError!(MFError(code: code, message: message));
      return;
    }

    if (error is MFError) {
      _onError!(error);
      return;
    }

    _onError!(MFError(code: 'unknown', message: error.toString()));
  }

  void _setupGooglePayEventStream({
    Function(String)? onInvoiceCreated,
    Function(String, MFGetPaymentStatusResponse)? onExecutePaymentSuccess,
    Function(String)? onSessionUpdated,
    Function(String)? onReceivedToken,
    Function(MFError)? onError,
  }) {
    _googlePayEventSubscription?.cancel();

    _onInvoiceCreated = onInvoiceCreated;
    _onExecutePaymentSuccess = onExecutePaymentSuccess;
    _onSessionUpdated = onSessionUpdated;
    _onReceivedToken = onReceivedToken;
    _onError = onError;

    if (onInvoiceCreated != null ||
        onExecutePaymentSuccess != null ||
        onSessionUpdated != null ||
        onReceivedToken != null ||
        onError != null) {
      _googlePayEventSubscription = _googlePayEventChannel
          .receiveBroadcastStream()
          .listen(_handleGooglePayEvent, onError: _handleGooglePayStreamError);
    }
  }

  Future<String> setupGooglePayLauncherAuto(
    String sessionId,
    MFGooglePayRequest googlePayRequest,
    Function(String invoiceId)? onInvoiceCreated,
    Function(String, MFGetPaymentStatusResponse)? onExecutePaymentSuccess,
    Function(MFError)? onError,
  ) async {
    // Clear previous setup to prevent callback leaks
    clearCurrentSetup();

    _setupGooglePayEventStream(
      onInvoiceCreated: onInvoiceCreated,
      onExecutePaymentSuccess: onExecutePaymentSuccess,
      onError: onError,
    );

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayLauncherAuto,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[sessionId, googlePayRequest]).timeout(
            paymentSetupTimeout, onTimeout: () {
      throw TimeoutException(
        'Google Pay auto setup timed out after ${paymentSetupTimeout.inSeconds} seconds',
        paymentSetupTimeout,
      );
    }) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  Future<String> setupGooglePayLauncherManual(
    String sessionId,
    MFGooglePayRequest googlePayRequest,
    Function(String sessionId)? onSessionUpdated,
    Function(MFError)? onError,
  ) async {
    // Clear previous setup to prevent callback leaks
    clearCurrentSetup();

    _setupGooglePayEventStream(
      onSessionUpdated: onSessionUpdated,
      onError: onError,
    );

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayLauncherManual,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[sessionId, googlePayRequest]).timeout(
            paymentSetupTimeout, onTimeout: () {
      throw TimeoutException(
        'Google Pay manual setup timed out after ${paymentSetupTimeout.inSeconds} seconds',
        paymentSetupTimeout,
      );
    }) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  Future<String> setupGooglePayLauncherTokenOnly(
    MFGooglePayRequest googlePayRequest,
    Function(String token)? onReceivedToken,
    Function(MFError)? onError,
  ) async {
    // Clear previous setup to prevent callback leaks
    clearCurrentSetup();

    _setupGooglePayEventStream(
      onReceivedToken: onReceivedToken,
      onError: onError,
    );

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayLauncherTokenOnly,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[googlePayRequest]).timeout(paymentSetupTimeout,
            onTimeout: () {
      throw TimeoutException(
        'Google Pay token-only setup timed out after ${paymentSetupTimeout.inSeconds} seconds',
        paymentSetupTimeout,
      );
    }) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  Future<bool> isGooglePayAvailable() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayAvailable,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[]).timeout(quickOperationTimeout, onTimeout: () {
      throw TimeoutException(
        'Google Pay availability check timed out after ${quickOperationTimeout.inSeconds} seconds',
        quickOperationTimeout,
      );
    }) as List<Object?>?;
    return modelParser<bool>(replyList);
  }

  Future<String> updateGooglePayRequestAmount(String amount) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayUpdateAmount,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[amount]).timeout(quickOperationTimeout, onTimeout: () {
      throw TimeoutException(
        'Google Pay amount update timed out after ${quickOperationTimeout.inSeconds} seconds',
        quickOperationTimeout,
      );
    }) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  Future<String> openGooglePaySheet() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayOpenSheet,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[]).timeout(quickOperationTimeout, onTimeout: () {
      throw TimeoutException(
        'Google Pay sheet open timed out after ${quickOperationTimeout.inSeconds} seconds',
        quickOperationTimeout,
      );
    }) as List<Object?>?;
    return modelParser<String>(replyList);
  }

  Future<MFGetPaymentStatusResponse> executeGooglePayPayment(
    MFExecutePaymentRequest executePaymentRequest,
    String lang,
    Function(String invoiceId)? onInvoiceCreated,
  ) async {
    _setupGooglePayEventStream(onInvoiceCreated: onInvoiceCreated);

    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      MFConstants.channelGPayName.googlePayExecutePayment,
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final List<Object?>? replyList = await channel
        .send(<Object?>[executePaymentRequest, lang]).timeout(
            paymentExecutionTimeout, onTimeout: () {
      throw TimeoutException(
        'Google Pay payment execution timed out after ${paymentExecutionTimeout.inSeconds} seconds',
        paymentExecutionTimeout,
      );
    }) as List<Object?>?;
    return modelParser<MFGetPaymentStatusResponse>(replyList);
  }
}
