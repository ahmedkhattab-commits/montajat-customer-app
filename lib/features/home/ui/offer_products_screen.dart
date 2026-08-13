import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/products/ui/widgets/product_listing_card.dart';

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
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                key: ValueKey('offer-product-${offer.itemCode}'),
                width: 176.w,
                height: 310.h,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductListingCard(
                        isGrid: true,
                        product: ProductListingItem(
                          itemCode: offer.itemCode,
                          name: offer.name,
                          nameEn: null,
                          uom: '',
                          unitsPerCarton: null,
                          imageUrl: offer.imageUrl,
                          price: offer.offerPrice,
                          currency: offer.currency,
                          availabilityLabel: '',
                          availabilityLabelEn: '',
                          isAvailable: true,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 9.h,
                      start: 9.w,
                      child: _Badge(
                        text: '-${offer.discountPercent.toStringAsFixed(0)}%',
                      ),
                    ),
                    PositionedDirectional(
                      top: 12.h,
                      end: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .94),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: const Color(0xFFE95353),
                              size: 15.sp,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '${offer.daysLeft}',
                              style: TextStyle(
                                color: const Color(0xFFE95353),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
