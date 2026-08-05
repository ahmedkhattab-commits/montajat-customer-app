import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Image.asset(
            ImageAsset.languageLogo,
            key: const ValueKey('login-logo'),
            width: 108.w,
            height: 116.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 30.h),
        Text(
          context.tr('login.title'),
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          context.tr('login.subtitle'),
          textAlign: TextAlign.start,
          style: TextStyle(
            color: AppColors.languageSubtitle,
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
