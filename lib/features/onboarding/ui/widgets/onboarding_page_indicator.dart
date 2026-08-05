import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.currentPage,
    required this.pageCount,
    super.key,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          key: ValueKey('onboarding-indicator-$index'),
          duration: const Duration(milliseconds: 220),
          width: index == currentPage ? 32.w : 12.w,
          height: 4.h,
          margin: EdgeInsetsDirectional.only(
            end: index == pageCount - 1 ? 0 : 5.w,
          ),
          decoration: BoxDecoration(
            color: index == currentPage
                ? AppColors.onboardingPrimary
                : AppColors.onboardingIndicator,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
