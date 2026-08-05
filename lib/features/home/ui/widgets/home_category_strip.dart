import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';

class HomeCategoryStrip extends StatelessWidget {
  const HomeCategoryStrip({required this.categories, super.key});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('home-categories'),
      height: 100.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          return SizedBox(
            width: 74.w,
            child: Column(
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.languageAccent.withValues(alpha: 0.55),
                    ),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(
                    category.icon,
                    size: 35.sp,
                    color: const Color(0xFFFFB629),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  context.tr(category.labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
