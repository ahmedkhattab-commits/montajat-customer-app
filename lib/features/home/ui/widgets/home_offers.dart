import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_section_header.dart';

class HomeOffers extends StatelessWidget {
  const HomeOffers({super.key});

  @override
  Widget build(BuildContext context) {
    const offers = [
      ImageAsset.homeCatFoodOffer,
      ImageAsset.homePetServicesOffer,
      ImageAsset.homeFineCareOffer,
    ];

    return Column(
      children: [
        const HomeSectionHeader(titleKey: 'home.offers_for_you'),
        SizedBox(height: 10.h),
        ...offers.map(
          (asset) => Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 10.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: AspectRatio(
                aspectRatio: 380 / 102,
                child: Image.asset(asset, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
