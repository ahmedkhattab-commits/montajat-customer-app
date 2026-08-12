import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/expiry_offer_banner_card.dart';

class OffersScreenArguments {
  const OffersScreenArguments({required this.offers});

  final List<HomeExpiryOfferModel> offers;
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({required this.arguments, super.key});

  final OffersScreenArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('offers-screen'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 74.h,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          context.tr('home.offers_for_you'),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.separated(
        key: const ValueKey('all-offers-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 30.h),
        itemCount: arguments.offers.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, index) => ExpiryOfferBannerCard(
          offer: arguments.offers[index],
          index: index,
          keyPrefix: 'all-expiry-offer',
        ),
      ),
    );
  }
}
