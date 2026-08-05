import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/home/data/models/home_product_model.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_section_header.dart';

class HomeProductSection extends StatelessWidget {
  const HomeProductSection({
    required this.titleKey,
    required this.products,
    super.key,
  });

  final String titleKey;
  final List<HomeProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionHeader(titleKey: titleKey),
        SizedBox(height: 12.h),
        SizedBox(
          height: 278.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (context, index) =>
                _ProductCard(product: products[index], index: index),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.index});

  final HomeProductModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('home-product-$index'),
      width: 174.w,
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Image.asset(product.imageAsset, fit: BoxFit.contain)),
          SizedBox(height: 7.h),
          Text(
            context.tr(product.nameKey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12.sp,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            context.tr(product.quantityKey),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 10.sp,
              color: const Color(0xFF8D8D8D),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            '${product.price} ${context.tr('home.currency')}',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 11.sp,
              color: const Color(0xFFFF5151),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 7.h),
          SizedBox(
            height: 40.h,
            child: FilledButton(
              onPressed: product.available ? () {} : null,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.onboardingPrimary,
                disabledBackgroundColor: const Color(0xFFFFF1C8),
                disabledForegroundColor: const Color(0xFFE3B332),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              child: Text(
                context.tr(
                  product.available ? 'home.add_to_cart' : 'home.unavailable',
                ),
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
