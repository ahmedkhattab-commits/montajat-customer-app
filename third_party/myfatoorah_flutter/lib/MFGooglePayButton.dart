// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/MFConstants.dart';
import 'package:myfatoorah_flutter/MFGPayFlutter.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

/// Configuration options for MFGooglePayButton appearance and behavior
///
/// Based on native Android MFGooglePayButton properties.
/// See: https://developers.google.com/pay/api/android/guides/brand-guidelines
///
/// Example:
/// ```dart
/// MFGooglePayButton(
///   config: MFGooglePayButtonConfig(
///     buttonType: MFButtonType.BUY,
///     buttonTheme: MFButtonTheme.LIGHT,
///     cornerRadius: 20,
///   ),
/// )
/// ```
class MFGooglePayButtonConfig {
  /// Button type: Determines the text and behavior of the button
  ///
  /// Use constants from [MFButtonType]:
  /// - [MFButtonType.PAY] (default): Standard payment button
  /// - [MFButtonType.BUY]: For purchases
  /// - [MFButtonType.BOOK]: For bookings
  /// - [MFButtonType.CHECKOUT]: For checkout flows
  /// - [MFButtonType.DONATE]: For donations
  /// - [MFButtonType.ORDER]: For orders
  /// - [MFButtonType.SUBSCRIBE]: For subscriptions
  /// - [MFButtonType.PLAIN]: Minimal button design
  final int buttonType;

  /// Button theme: Visual appearance of the button
  ///
  /// Use constants from [MFButtonTheme]:
  /// - [MFButtonTheme.DARK] (default): Dark theme for dark backgrounds
  /// - [MFButtonTheme.LIGHT]: Light theme for light backgrounds
  final int buttonTheme;

  /// Corner radius in pixels
  /// Controls how rounded the button corners appear
  ///
  /// Defaults to 10
  final int cornerRadius;

  const MFGooglePayButtonConfig({
    this.buttonType = MFButtonType.PAY,
    this.buttonTheme = MFButtonTheme.DARK,
    this.cornerRadius = 10,
  });

  /// Convert to map for platform channel
  Map<String, dynamic> toMap() => {
        'buttonType': buttonType,
        'buttonTheme': buttonTheme,
        'cornerRadius': cornerRadius,
      };

  /// Default configuration
  static const defaultConfig = MFGooglePayButtonConfig();

  /// Copy with method for creating modified configs
  MFGooglePayButtonConfig copyWith({
    int? buttonType,
    int? buttonTheme,
    int? cornerRadius,
  }) {
    return MFGooglePayButtonConfig(
      buttonType: buttonType ?? this.buttonType,
      buttonTheme: buttonTheme ?? this.buttonTheme,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MFGooglePayButtonConfig &&
          runtimeType == other.runtimeType &&
          buttonType == other.buttonType &&
          buttonTheme == other.buttonTheme &&
          cornerRadius == other.cornerRadius;

  @override
  int get hashCode =>
      buttonType.hashCode ^ buttonTheme.hashCode ^ cornerRadius.hashCode;

  @override
  String toString() =>
      'MFGooglePayButtonConfig(buttonType: $buttonType, buttonTheme: $buttonTheme, cornerRadius: $cornerRadius)';
}

abstract class IMFGooglePayButton {
  /// @deprecated Use setupWithAutoExecute instead. This method uses deprecated MFGooglePayHelper.
  Future<MFGetPaymentStatusResponse> setupGooglePayHelper(
      String sessionId,
      MFGooglePayRequest googlePayRequest,
      Function(String invoiceId) onInvoiceCreated);

  /// @deprecated Use setupTokenOnly instead. This method uses deprecated MFGooglePayTokenHelper.
  Future<String> setupGooglePayTokenHelper(MFGooglePayRequest googlePayRequest);

  /// Setup Google Pay with Auto execution mode using MFGooglePayLauncher
  ///
  /// This mode automatically executes payment after getting the Google Pay token.
  /// Use this for simple one-time payments where you want automatic execution.
  ///
  /// Callbacks:
  /// - [onInvoiceCreated]: Called when invoice is created (before payment execution)
  /// - [onExecutePaymentSuccess]: Called when payment is executed successfully with invoice ID and payment status
  /// - [onError]: Called if an error occurs during the payment process
  ///
  /// Returns setup status after configuration completes
  Future<String> setupWithAutoExecute(
      String sessionId, MFGooglePayRequest googlePayRequest,
      {Function(String invoiceId)? onInvoiceCreated,
      Function(String, MFGetPaymentStatusResponse)? onExecutePaymentSuccess,
      Function(MFError)? onError});

  /// Setup Google Pay with Manual execution mode using MFGooglePayLauncher
  ///
  /// This mode gets the Google Pay token first, then you manually execute the payment.
  /// Use this when you need full control over the payment flow.
  ///
  /// Callbacks:
  /// - [onSessionUpdated]: Called when session is updated with the Google Pay token
  /// - [onError]: Called if an error occurs during token generation
  ///
  /// Returns the updated session ID after setup completes
  Future<String> setupWithManualExecute(
      String sessionId, MFGooglePayRequest googlePayRequest,
      {Function(String sessionId)? onSessionUpdated,
      Function(MFError)? onError});

  /// Setup Google Pay with TokenOnly mode using MFGooglePayLauncher
  ///
  /// This mode gets a Google Pay token without executing payment.
  /// Use this to save tokens for future recurring payments.
  ///
  /// Callbacks:
  /// - [onReceivedToken]: Called when Google Pay token is successfully received
  /// - [onError]: Called if an error occurs during token generation
  ///
  /// Returns the token after setup completes
  Future<String> setupTokenOnly(MFGooglePayRequest googlePayRequest,
      {Function(String token)? onReceivedToken, Function(MFError)? onError});

  /// Check if Google Pay is available
  Future<bool> isGooglePayAvailable();

  /// Update the request amount for dynamic pricing
  Future<String> updateRequestAmount(String amount);

  /// Manually open the Google Pay payment sheet
  Future<String> openGooglePaySheet();

  /// Execute payment manually (for Manual mode)
  ///
  /// Use this method after setupWithManualExecute to execute the payment.
  /// You can add custom validation or business logic before calling this method.
  ///
  /// Callbacks:
  /// - [onInvoiceCreated]: Called when invoice is created (before payment execution)
  ///
  /// Returns the payment status response after execution completes
  Future<MFGetPaymentStatusResponse> executePayment(
      MFExecutePaymentRequest executePaymentRequest, String lang,
      {Function(String invoiceId)? onInvoiceCreated});

  /// Validate button configuration
  ///
  /// Throws [ArgumentError] if configuration is invalid
  void validateConfig(MFGooglePayButtonConfig config) {
    // Validate buttonType
    const validButtonTypes = {
      MFButtonType.BUY,
      MFButtonType.BOOK,
      MFButtonType.CHECKOUT,
      MFButtonType.DONATE,
      MFButtonType.ORDER,
      MFButtonType.PAY,
      MFButtonType.SUBSCRIBE,
      MFButtonType.PLAIN,
    };

    if (!validButtonTypes.contains(config.buttonType)) {
      throw ArgumentError(
          'buttonType must be one of MFButtonType constants (PAY, BUY, BOOK, CHECKOUT, DONATE, ORDER, SUBSCRIBE, PLAIN). Got: ${config.buttonType}');
    }

    // Validate buttonTheme
    const validButtonThemes = {
      MFButtonTheme.DARK,
      MFButtonTheme.LIGHT,
    };

    if (!validButtonThemes.contains(config.buttonTheme)) {
      throw ArgumentError(
          'buttonTheme must be one of MFButtonTheme constants (DARK, LIGHT). Got: ${config.buttonTheme}');
    }

    // Validate cornerRadius
    if (config.cornerRadius < 0) {
      throw ArgumentError(
          'cornerRadius must be non-negative. Got: ${config.cornerRadius}');
    }
  }
}

// ignore: must_be_immutable
class MFGooglePayButton extends StatefulWidget implements IMFGooglePayButton {
  /// Button appearance configuration
  final MFGooglePayButtonConfig config;

  const MFGooglePayButton({
    super.key,
    this.config = MFGooglePayButtonConfig.defaultConfig,
  });

  MFGPayFlutter get _mfGPayFlutter => MFGooglePay;

  @override
  State<MFGooglePayButton> createState() => _MFGooglePayButton();

  /// @deprecated Use setupWithAutoExecute (for auto execute payment) or setupWithManualExecute (for manual execute payment) instead. This method uses deprecated MFGooglePayHelper.
  @override
  @Deprecated(
      'Use setupWithAutoExecute or setupWithManualExecute instead. This method uses deprecated MFGooglePayHelper.')
  Future<MFGetPaymentStatusResponse> setupGooglePayHelper(
      String sessionId,
      MFGooglePayRequest googlePayRequest,
      Function(String invoiceId) onInvoiceCreated) async {
    return await MFSDK.setupGooglePayHelper(
        sessionId, googlePayRequest, onInvoiceCreated);
  }

  /// @deprecated Use setupTokenOnly instead. This method uses deprecated MFGooglePayTokenHelper.
  @override
  @Deprecated(
      'Use setupTokenOnly instead. This method uses deprecated MFGooglePayTokenHelper.')
  Future<String> setupGooglePayTokenHelper(
      MFGooglePayRequest googlePayRequest) async {
    return await MFSDK.setupGooglePayTokenHelper(googlePayRequest);
  }

  @override
  Future<String> setupWithAutoExecute(
      String sessionId, MFGooglePayRequest googlePayRequest,
      {Function(String invoiceId)? onInvoiceCreated,
      Function(String, MFGetPaymentStatusResponse)? onExecutePaymentSuccess,
      Function(MFError)? onError}) async {
    return await _mfGPayFlutter.setupGooglePayLauncherAuto(sessionId,
        googlePayRequest, onInvoiceCreated, onExecutePaymentSuccess, onError);
  }

  @override
  Future<String> setupWithManualExecute(
      String sessionId, MFGooglePayRequest googlePayRequest,
      {Function(String sessionId)? onSessionUpdated,
      Function(MFError)? onError}) async {
    return await _mfGPayFlutter.setupGooglePayLauncherManual(
        sessionId, googlePayRequest, onSessionUpdated, onError);
  }

  @override
  Future<String> setupTokenOnly(MFGooglePayRequest googlePayRequest,
      {Function(String token)? onReceivedToken,
      Function(MFError)? onError}) async {
    return await _mfGPayFlutter.setupGooglePayLauncherTokenOnly(
        googlePayRequest, onReceivedToken, onError);
  }

  @override
  Future<bool> isGooglePayAvailable() async {
    return await _mfGPayFlutter.isGooglePayAvailable();
  }

  @override
  Future<String> updateRequestAmount(String amount) async {
    return await _mfGPayFlutter.updateGooglePayRequestAmount(amount);
  }

  @override
  Future<String> openGooglePaySheet() async {
    return await _mfGPayFlutter.openGooglePaySheet();
  }

  @override
  Future<MFGetPaymentStatusResponse> executePayment(
      MFExecutePaymentRequest executePaymentRequest, String lang,
      {Function(String invoiceId)? onInvoiceCreated}) async {
    return await _mfGPayFlutter.executeGooglePayPayment(
        executePaymentRequest, lang, onInvoiceCreated);
  }

  @override
  void validateConfig(MFGooglePayButtonConfig config) {
    // Validate buttonType
    const validButtonTypes = {
      MFButtonType.BUY,
      MFButtonType.BOOK,
      MFButtonType.CHECKOUT,
      MFButtonType.DONATE,
      MFButtonType.ORDER,
      MFButtonType.PAY,
      MFButtonType.SUBSCRIBE,
      MFButtonType.PLAIN,
    };

    if (!validButtonTypes.contains(config.buttonType)) {
      throw ArgumentError(
          'buttonType must be one of MFButtonType constants (PAY, BUY, BOOK, CHECKOUT, DONATE, ORDER, SUBSCRIBE, PLAIN). Got: ${config.buttonType}');
    }

    // Validate buttonTheme
    const validButtonThemes = {
      MFButtonTheme.DARK,
      MFButtonTheme.LIGHT,
    };

    if (!validButtonThemes.contains(config.buttonTheme)) {
      throw ArgumentError(
          'buttonTheme must be one of MFButtonTheme constants (DARK, LIGHT). Got: ${config.buttonTheme}');
    }

    // Validate cornerRadius
    if (config.cornerRadius < 0) {
      throw ArgumentError(
          'cornerRadius must be non-negative. Got: ${config.cornerRadius}');
    }
  }
}

class _MFGooglePayButton extends State<MFGooglePayButton> {
  @override
  void initState() {
    super.initState();
    // Validate configuration on initialization
    try {
      widget.validateConfig(widget.config);
    } catch (e) {
      debugPrint('MFGooglePayButton config validation error: $e');
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Do NOT dispose the singleton
    // The singleton is shared across all button instances
    // Disposing it here would break other buttons
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = MFConstants.MFGooglePayButtonModuleNAME;

    // Pass configuration parameters to native side
    Map<String, dynamic> creationParams = widget.config.toMap();

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
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        );
      case TargetPlatform.iOS:
        // Google Pay is not supported on iOS
        // Use MFApplePayButton for iOS instead
        return const SizedBox.shrink();
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}
