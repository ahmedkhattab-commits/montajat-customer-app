import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_cubit.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_state.dart';
import 'package:montajat_customer_app/features/verification/ui/widgets/verification_code_fields.dart';
import 'package:montajat_customer_app/features/verification/ui/widgets/verification_header.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificationCubit, VerificationState>(
      listener: (context, state) {
        if (state is VerificationCodeAccepted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.profile, (route) => false);
        } else if (state is VerificationRequestFailure) {
          AppConstant.toast(_message(context, state.message), false, context);
        } else if (state is VerificationResent) {
          AppConstant.toast(
            context.tr('verification.resend_success'),
            true,
            context,
          );
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10.h),
                const VerificationHeader(),
                SizedBox(height: 30.h),
                const _SecurityMark(),
                SizedBox(height: 38.h),
                Text(
                  context.tr(
                    'verification.instruction',
                    namedArgs: {'phone': _formattedPhone(widget.phoneNumber)},
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 16.sp,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF242424),
                  ),
                ),
                TextButton(
                  key: const ValueKey('verification-change-phone'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.tr('verification.change_phone'),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.languageAccent,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.languageAccent,
                    ),
                  ),
                ),
                SizedBox(height: 17.h),
                VerificationCodeFields(
                  onChanged: (code) {
                    _code = code;
                    context.read<VerificationCubit>().clearValidation();
                  },
                ),
                if (state is VerificationValidationFailure) ...[
                  SizedBox(height: 8.h),
                  Text(
                    context.tr('verification.code_error'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12.sp,
                      color: AppColors.errorColor100,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                _ResendRow(
                  mobile: widget.phoneNumber,
                  secondsRemaining: state.secondsRemaining,
                  busy:
                      state is VerificationSubmitting ||
                      state is VerificationResending,
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  height: 60.h,
                  child: FilledButton(
                    key: const ValueKey('verification-confirm'),
                    onPressed:
                        state is VerificationSubmitting ||
                            state is VerificationResending
                        ? null
                        : () => context.read<VerificationCubit>().confirm(
                            mobile: widget.phoneNumber,
                            code: _code,
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.onboardingPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                    ),
                    child: state is VerificationSubmitting
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.tr('verification.confirm'),
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formattedPhone(String phone) {
    if (phone.length <= 7) return phone;
    final lastFour = phone.substring(phone.length - 4);
    final middle = phone.substring(phone.length - 7, phone.length - 4);
    final start = phone.substring(0, phone.length - 7);
    return '$start $middle $lastFour';
  }

  String _message(BuildContext context, String message) =>
      message.startsWith('auth_errors.') ? context.tr(message) : message;
}

class _SecurityMark extends StatelessWidget {
  const _SecurityMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const ValueKey('verification-password-icon'),
        width: 148.w,
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Icon(Icons.password_rounded, size: 66.sp, color: Colors.black),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.mobile,
    required this.secondsRemaining,
    required this.busy,
  });

  final String mobile;
  final int secondsRemaining;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    final timer = '$minutes:$seconds';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('verification.resend_prefix'),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 15.sp,
            color: const Color(0xFFA0A0A0),
          ),
        ),
        if (secondsRemaining > 0)
          Text(
            ' $timer',
            textDirection: ui.TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 15.sp,
              color: AppColors.onboardingPrimary,
            ),
          )
        else
          TextButton(
            key: const ValueKey('verification-resend'),
            onPressed: busy
                ? null
                : () => context.read<VerificationCubit>().resend(mobile),
            child: Text(context.tr('verification.resend_action')),
          ),
      ],
    );
  }
}
