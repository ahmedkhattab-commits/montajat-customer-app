import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';

class LanguageSelectionHeader extends StatelessWidget {
  const LanguageSelectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          ImageAsset.languageLogo,
          key: const ValueKey('language-logo'),
          width: 116.w,
          height: 99.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 24.11.h),
        Text(
          context.tr('language_selection.title'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            height: 1.6,
          ),
        ),
        Text(
          context.tr('language_selection.subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.languageSubtitle,
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
