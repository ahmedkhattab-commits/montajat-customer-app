import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';

class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    required this.enabled,
    required this.onLogin,
    required this.onCreateAccount,
    super.key,
  });

  final bool enabled;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: 'IBMPlexSansArabic',
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58.h,
          child: FilledButton(
            key: const ValueKey('onboarding-login'),
            onPressed: enabled ? onLogin : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.onboardingPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.onboardingPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Text(context.tr('onboarding.login'), style: textStyle),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 58.h,
          child: FilledButton(
            key: const ValueKey('onboarding-create-account'),
            onPressed: enabled ? onCreateAccount : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.onboardingSecondary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.onboardingSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Text(
              context.tr('onboarding.create_account'),
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
