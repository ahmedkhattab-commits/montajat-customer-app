import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/expiry_offer_banner_card.dart';

class OffersScreenArguments {
  const OffersScreenArguments({required this.offers});

  final List<HomeExpiryOfferModel> offers;
}

class OffersScreen extends StatefulWidget {
  const OffersScreen({required this.arguments, super.key});

  final OffersScreenArguments arguments;

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  static const _pageSize = 3;
  final ScrollController _controller = ScrollController();
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_loadNextPage);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_loadNextPage)
      ..dispose();
    super.dispose();
  }

  void _loadNextPage() {
    if (!_controller.hasClients || _controller.position.extentAfter > 280) {
      return;
    }
    final total = widget.arguments.offers.length;
    if (_visibleCount >= total) return;
    setState(() => _visibleCount = (_visibleCount + _pageSize).clamp(0, total));
  }

  @override
  Widget build(BuildContext context) {
    final visibleCount = _visibleCount.clamp(0, widget.arguments.offers.length);
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
        controller: _controller,
        key: const ValueKey('all-offers-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 30.h),
        itemCount: visibleCount,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, index) => ExpiryOfferBannerCard(
          offer: widget.arguments.offers[index],
          index: index,
          keyPrefix: 'all-expiry-offer',
        ),
      ),
    );
  }
}
