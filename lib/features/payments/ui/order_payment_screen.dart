import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/myfatoorah_config.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';
import 'package:montajat_customer_app/features/payments/data/models/online_payment_models.dart';
import 'package:montajat_customer_app/features/payments/logic/order_payment_cubit.dart';
import 'package:montajat_customer_app/features/payments/logic/order_payment_state.dart';
import 'package:montajat_customer_app/features/payments/ui/hosted_payment_webview_screen.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class OrderPaymentScreen extends StatefulWidget {
  const OrderPaymentScreen({required this.order, super.key});

  final OrderModel order;

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen>
    with WidgetsBindingObserver {
  late final MFCardPaymentView _cardView;
  late final MFGooglePayButton _googlePayButton;
  String? _loadedSessionId;
  OnlinePaymentSessionModel? _pendingSession;
  bool _isCardViewReady = false;
  String? _initializingSessionId;
  String? _googlePayPreparedSessionId;
  bool _isGooglePayPreparing = false;

  @override
  void initState() {
    super.initState();
    _cardView = MFCardPaymentView(
      cardViewStyle: _cardViewStyle(),
      onPlatformViewCreated: _onCardViewCreated,
    );
    _googlePayButton = const MFGooglePayButton(
      config: MFGooglePayButtonConfig(
        buttonType: MFButtonType.PAY,
        buttonTheme: MFButtonTheme.DARK,
        cornerRadius: 8,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  MFCardViewStyle _cardViewStyle() {
    final style = MFCardViewStyle();
    style.direction = 'ltr';
    style.cardHeight = 245;
    style.hideCardIcons = false;
    style.input?.borderColor = 0xFFE3E3E3;
    style.input?.borderRadius = 8;
    style.input?.borderWidth = 1;
    return style;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final cubit = context.read<OrderPaymentCubit>();
    if (cubit.state.status == OrderPaymentStatus.awaitingConfirmation) {
      cubit.verifyPayment();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      title: Text(context.tr('payments.title')),
    ),
    body: BlocConsumer<OrderPaymentCubit, OrderPaymentState>(
      listenWhen: (previous, current) =>
          previous.payment?.paymentUrl != current.payment?.paymentUrl ||
          previous.errorMessageKey != current.errorMessageKey ||
          previous.status != current.status ||
          previous.selectedGateway != current.selectedGateway,
      listener: (context, state) async {
        final message = state.errorMessageKey;
        if (message != null) {
          AppConstant.toast(
            message.startsWith('payments.') ? context.tr(message) : message,
            false,
            context,
          );
        }
        final paymentUrl = state.payment?.paymentUrl;
        if (state.openPaymentPage &&
            state.status == OrderPaymentStatus.awaitingConfirmation &&
            paymentUrl != null) {
          context.read<OrderPaymentCubit>().markPaymentPageOpened();
          await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (_) =>
                  HostedPaymentWebViewScreen(paymentUrl: paymentUrl),
            ),
          );
          if (context.mounted) {
            await context.read<OrderPaymentCubit>().verifyPayment();
          }
        }
        final session = state.session;
        if (state.status == OrderPaymentStatus.sdkReady &&
            session != null &&
            _selectedMethod(state)?.type == OnlinePaymentMethodType.card &&
            session.sessionId != _loadedSessionId) {
          _pendingSession = session;
          _loadPendingCardSession();
        }
        if (state.status == OrderPaymentStatus.sdkReady &&
            session != null &&
            _selectedMethod(state)?.type == OnlinePaymentMethodType.googlePay &&
            session.sessionId != _googlePayPreparedSessionId) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _prepareGooglePay(state),
          );
        }
        if (state.status == OrderPaymentStatus.success && context.mounted) {
          Navigator.of(context).pop(true);
        } else if (state.payment?.status.toLowerCase() == 'cancelled' &&
            context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      builder: (context, state) {
        if (state.status == OrderPaymentStatus.initial ||
            state.status == OrderPaymentStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == OrderPaymentStatus.failure) {
          return Center(
            child: FilledButton.icon(
              onPressed: context.read<OrderPaymentCubit>().loadMethods,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('payments.retry')),
            ),
          );
        }
        return _PaymentBody(
          order: widget.order,
          state: state,
          cardView: _cardView,
          googlePayButton: _googlePayButton,
          isGooglePayPreparing: _isGooglePayPreparing,
          onSubmitSdk: _submitSdkPayment,
        );
      },
    ),
  );

  Future<void> _submitSdkPayment() async {
    try {
      final paymentCubit = context.read<OrderPaymentCubit>();
      if (kDebugMode) {
        debugPrint('[Payment SDK][4/6] Validating card inside SDK');
      }
      final validatedSessionId = await _cardView.validate(
        currency: widget.order.currency,
      );
      final backendSessionId = paymentCubit.state.session?.sessionId;
      if (kDebugMode) {
        debugPrint(
          '[Payment SDK][4/6] Card validated; session_id=[REDACTED]; '
          'matches_backend_session=${validatedSessionId == backendSessionId}',
        );
      }
      if (!mounted) return;
      await paymentCubit.executeSdkPayment(
        backendSessionId ?? validatedSessionId,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Payment SDK][ERROR] Card validation failed: $error');
      }
      if (!mounted) return;
      AppConstant.toast(context.tr('payments.card_invalid'), false, context);
    }
  }

  void _onCardViewCreated() {
    _isCardViewReady = true;
    _loadPendingCardSession();
  }

  Future<void> _loadPendingCardSession() async {
    final session = _pendingSession;
    if (!_isCardViewReady ||
        session == null ||
        session.sessionId == _loadedSessionId ||
        session.sessionId == _initializingSessionId) {
      return;
    }
    _initializingSessionId = session.sessionId;
    if (!MyFatoorahConfig.hasApiKey) {
      _initializingSessionId = null;
      if (mounted) {
        AppConstant.toast(
          context.tr('payments.sdk_key_missing'),
          false,
          context,
        );
      }
      return;
    }
    if (kDebugMode) {
      debugPrint(
        '[Payment SDK][4/6] Initializing SDK and loading card form; '
        'session_id=[REDACTED]; country=${session.countryCode}',
      );
    }
    await MFSDK.init(
      MyFatoorahConfig.apiKey,
      session.countryCode,
      MyFatoorahConfig.environment,
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted || _pendingSession?.sessionId != session.sessionId) {
      _initializingSessionId = null;
      return;
    }
    _loadedSessionId = session.sessionId;
    _initializingSessionId = null;
    _cardView.load(
      MFInitiateSessionResponse(
        sessionId: session.sessionId,
        countryCode: session.countryCode,
      ),
      (_) {},
    );
  }

  Future<void> _prepareGooglePay(OrderPaymentState state) async {
    final session = state.session;
    final method = _selectedMethod(state);
    if (session == null ||
        method == null ||
        method.type != OnlinePaymentMethodType.googlePay ||
        _isGooglePayPreparing ||
        _googlePayPreparedSessionId == session.sessionId ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    if (!MyFatoorahConfig.hasApiKey) {
      AppConstant.toast(context.tr('payments.sdk_key_missing'), false, context);
      return;
    }
    setState(() => _isGooglePayPreparing = true);
    try {
      await MFSDK.init(
        MyFatoorahConfig.apiKey,
        session.countryCode,
        MyFatoorahConfig.environment,
      );
      await _googlePayButton.setupWithManualExecute(
        session.sessionId,
        MFGooglePayRequest(
          totalPrice: method.totalAmount.toStringAsFixed(2),
          merchantId: MyFatoorahConfig.googlePayMerchantId.trim().isEmpty
              ? null
              : MyFatoorahConfig.googlePayMerchantId.trim(),
          merchantName: 'Muntajat',
          countryCode: session.countryCode == 'SAU'
              ? 'SA'
              : session.countryCode,
          currencyIso: method.currency,
        ),
        onSessionUpdated: (updatedSessionId) async {
          if (!mounted) return;
          await context.read<OrderPaymentCubit>().executeSdkPayment(
            updatedSessionId,
          );
        },
        onError: (error) {
          if (!mounted) return;
          AppConstant.toast(
            error.message?.trim().isNotEmpty == true
                ? error.message!
                : context.tr('payments.failed'),
            false,
            context,
          );
        },
      );
      _googlePayPreparedSessionId = session.sessionId;
    } catch (error) {
      if (mounted) {
        AppConstant.toast(
          context.tr('payments.method_unavailable'),
          false,
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _isGooglePayPreparing = false);
    }
  }

  OnlinePaymentMethodModel? _selectedMethod(OrderPaymentState state) {
    final selectedGateway = state.selectedGateway;
    if (selectedGateway == null) return null;
    for (final method in state.methods) {
      if (method.gateway == selectedGateway) return method;
    }
    return null;
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody({
    required this.order,
    required this.state,
    required this.cardView,
    required this.googlePayButton,
    required this.isGooglePayPreparing,
    required this.onSubmitSdk,
  });

  final OrderModel order;
  final OrderPaymentState state;
  final Widget cardView;
  final Widget googlePayButton;
  final bool isGooglePayPreparing;
  final VoidCallback onSubmitSdk;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == OrderPaymentStatus.submitting;
    final awaiting = state.status == OrderPaymentStatus.awaitingConfirmation;
    OnlinePaymentMethodModel? selectedMethod;
    for (final method in state.methods) {
      if (method.gateway == state.selectedGateway) {
        selectedMethod = method;
        break;
      }
    }
    final visibleMethods = state.methods.where((method) {
      if (method.type == OnlinePaymentMethodType.googlePay) {
        return defaultTargetPlatform == TargetPlatform.android;
      }
      if (method.type == OnlinePaymentMethodType.applePay) {
        return defaultTargetPlatform == TargetPlatform.iOS;
      }
      return true;
    });
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
            children: [
              _AmountCard(order: order),
              SizedBox(height: 24.h),
              Text(
                context.tr('payments.choose_method'),
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12.h),
              if (state.methods.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(child: Text(context.tr('payments.no_methods'))),
                )
              else
                ...visibleMethods.map(
                  (method) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _MethodCard(
                      method: method,
                      selected: state.selectedGateway == method.gateway,
                      onTap:
                          state.status == OrderPaymentStatus.ready ||
                              state.status == OrderPaymentStatus.sdkReady
                          ? () => context
                                .read<OrderPaymentCubit>()
                                .selectMethod(method.gateway)
                          : null,
                    ),
                  ),
                ),
              if (state.session != null &&
                  selectedMethod?.type == OnlinePaymentMethodType.card) ...[
                SizedBox(height: 14.h),
                SizedBox(height: 245.h, child: cardView),
              ],
              if (state.session != null &&
                  selectedMethod?.type ==
                      OnlinePaymentMethodType.googlePay) ...[
                SizedBox(height: 18.h),
                if (isGooglePayPreparing)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(height: 50.h, child: googlePayButton),
              ],
              if (selectedMethod?.type == OnlinePaymentMethodType.stcPay) ...[
                SizedBox(height: 18.h),
                _PaymentMethodHint(text: context.tr('payments.stc_hint')),
              ],
              if (selectedMethod?.type == OnlinePaymentMethodType.applePay) ...[
                SizedBox(height: 18.h),
                _PaymentMethodHint(text: context.tr('payments.apple_hint')),
              ],
            ],
          ),
        ),
        if (!(state.status == OrderPaymentStatus.sdkReady &&
            selectedMethod?.type == OnlinePaymentMethodType.googlePay))
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
              child: FilledButton(
                onPressed: isSubmitting
                    ? null
                    : state.status == OrderPaymentStatus.sdkReady &&
                          selectedMethod?.type == OnlinePaymentMethodType.card
                    ? onSubmitSdk
                    : awaiting
                    ? context.read<OrderPaymentCubit>().verifyPayment
                    : state.selectedGateway == null
                    ? null
                    : context.read<OrderPaymentCubit>().pay,
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(54.h),
                  backgroundColor: AppColors.onboardingPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        context.tr(
                          awaiting ? 'payments.verify' : 'payments.pay_now',
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PaymentMethodHint extends StatelessWidget {
  const _PaymentMethodHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F8FC),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(text, textAlign: TextAlign.center),
  );
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F8FC),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      children: [
        Icon(Icons.receipt_long_rounded, color: AppColors.onboardingPrimary),
        SizedBox(width: 12.w),
        Expanded(child: Text(context.tr('payments.amount'))),
        Text(
          '${order.grandTotal.toStringAsFixed(2)} ${order.currency}',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final OnlinePaymentMethodModel method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? AppColors.onboardingPrimary
                : const Color(0xFFE3E3E3),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? AppColors.onboardingPrimary
                  : const Color(0xFFBDBDBD),
            ),
            SizedBox(width: 10.w),
            if (method.imageUrl != null) ...[
              SizedBox(
                width: 48.w,
                height: 32.h,
                child: CachedNetworkImage(
                  imageUrl: method.imageUrl!,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const Icon(Icons.payment_rounded),
                ),
              ),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.localizedName(languageCode),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.tr(
                      'payments.total_with_fee',
                      namedArgs: {
                        'total': method.totalAmount.toStringAsFixed(2),
                        'currency': method.currency,
                      },
                    ),
                    style: TextStyle(
                      color: const Color(0xFF777777),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
