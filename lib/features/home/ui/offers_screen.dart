import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/logic/offers_cubit.dart';
import 'package:montajat_customer_app/features/home/logic/offers_state.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/expiry_offer_banner_card.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
    body: BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) => _OffersContent(state: state),
    ),
  );
}

class _OffersContent extends StatelessWidget {
  const _OffersContent({required this.state});

  final OffersState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadStatus == OffersLoadStatus.initial ||
        state.loadStatus == OffersLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadStatus == OffersLoadStatus.failure) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 260.h),
          Center(
            child: Column(
              children: [
                Text(
                  context.tr(
                    state.errorMessageKey ?? 'auth_errors.request_failed',
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  onPressed: context.read<OffersCubit>().loadOffers,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 260.h),
          Center(child: Text(context.tr('offers.empty'))),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 240) {
          context.read<OffersCubit>().loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        color: const Color(0xFF4F86C6),
        onRefresh: context.read<OffersCubit>().refreshOffers,
        child: ListView.separated(
          key: const ValueKey('all-offers-list'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 30.h),
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (_, index) {
            if (index == state.items.length) {
              return SizedBox(
                key: const ValueKey('offers-pagination-loader'),
                height: 56.h,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return ExpiryOfferBannerCard(
              offer: state.items[index],
              keyPrefix: 'all-expiry-offer',
            );
          },
        ),
      ),
    );
  }
}
