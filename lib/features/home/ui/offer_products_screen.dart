import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/cart/ui/widgets/add_to_cart_button.dart';

class OfferProductsArguments {
  const OfferProductsArguments({required this.offer, required this.imageAsset});

  final HomeExpiryOfferModel offer;
  final String imageAsset;
}

class OfferProductsScreen extends StatelessWidget {
  const OfferProductsScreen({required this.arguments, super.key});

  final OfferProductsArguments arguments;

  @override
  Widget build(BuildContext context) {
    final offer = arguments.offer;
    return Scaffold(
      key: const ValueKey('offer-products-screen'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('home.offers_for_you'),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7.r),
              child: AspectRatio(
                aspectRatio: 380 / 102,
                child: offer.imageUrl == null
                    ? Image.asset(arguments.imageAsset, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: offer.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: Color(0xFFF3F3F3)),
                        errorWidget: (_, _, _) => Image.asset(
                          arguments.imageAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              key: ValueKey('offer-product-${offer.itemCode}'),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE8E8E8)),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(
                        text: '-${offer.discountPercent.toStringAsFixed(0)}%',
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFFE95353),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '${offer.daysLeft}',
                        style: TextStyle(
                          color: const Color(0xFFE95353),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    offer.name,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 17.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    offer.message,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13.sp,
                      height: 1.5,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Text(
                        '${offer.offerPrice.toStringAsFixed(2)} ${offer.currency}',
                        style: TextStyle(
                          color: AppColors.onboardingPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        offer.basePrice.toStringAsFixed(2),
                        style: TextStyle(
                          color: const Color(0xFF999999),
                          fontSize: 13.sp,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    height: 48.h,
                    child: AddToCartButton(
                      itemCode: offer.itemCode,
                      quantity: offer.suggestedQuantity.toInt().clamp(1, 9999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB629),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
