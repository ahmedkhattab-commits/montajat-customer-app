import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    this.titleKey,
    this.title,
    this.actionKey,
    this.onShowAll,
    super.key,
  }) : assert(titleKey != null || title != null);

  final String? titleKey;
  final String? title;
  final String? actionKey;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title ?? context.tr(titleKey!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: InkWell(
              key: onShowAll == null
                  ? null
                  : ValueKey('show-all-${actionKey ?? titleKey ?? title}'),
              onTap: onShowAll,
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Text(
                  context.tr('home.show_all'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14.sp,
                    color: const Color(0xFFA5A5A5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
