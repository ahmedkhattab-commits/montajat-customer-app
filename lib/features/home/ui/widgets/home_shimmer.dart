import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF8F8F8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(height: 98.h, radius: 8.r),
            SizedBox(height: 18.h),
            _block(width: 110.w, height: 18.h),
            SizedBox(height: 12.h),
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == 3 ? 0 : 8.w,
                    ),
                    child: _block(height: 75.h, radius: 8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 22.h),
            _block(width: 130.w, height: 18.h),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 9.h,
                crossAxisSpacing: 9.w,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (_, _) => _block(radius: 8.r),
            ),
          ],
        ),
      ),
    );
  }

  Widget _block({double? width, double? height, double radius = 4}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
