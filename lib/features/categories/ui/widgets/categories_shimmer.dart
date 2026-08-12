import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(22.w, 8.h, 22.w, 30.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 22.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.67,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => Shimmer.fromColors(
            baseColor: const Color(0xFFE8E8E8),
            highlightColor: const Color(0xFFF8F8F8),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 7.h),
                Container(
                  width: 52.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          childCount: 16,
        ),
      ),
    );
  }
}
