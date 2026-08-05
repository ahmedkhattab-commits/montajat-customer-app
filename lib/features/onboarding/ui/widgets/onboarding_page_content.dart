import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/onboarding/data/models/onboarding_page_model.dart';
import 'package:montajat_customer_app/features/onboarding/ui/widgets/onboarding_page_indicator.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.page,
    required this.index,
    required this.pageCount,
    required this.currentPage,
    super.key,
  });

  final OnboardingPageModel page;
  final int index;
  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 14.h),
          SizedBox(
            height: 72.h,
            child: page.showLogo
                ? Image.asset(
                    ImageAsset.languageLogo,
                    width: 72.w,
                    height: 62.h,
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          SizedBox(height: page.showLogo ? 32.h : 10.h),
          Image.asset(
            page.imageAsset,
            key: ValueKey('onboarding-image-$index'),
            width: 320.w,
            height: 270.h,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: 30.h),
          OnboardingPageIndicator(
            currentPage: currentPage,
            pageCount: pageCount,
          ),
          SizedBox(height: 40.h),
          Text(
            context.tr(page.descriptionKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.75,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
