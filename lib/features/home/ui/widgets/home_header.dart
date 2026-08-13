import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_cubit.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SizedBox(
        key: const ValueKey('home-top-header'),
        height: 145.h,
        child: ColoredBox(
          color: AppColors.onboardingPrimary,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 10.h,
              left: 24.w,
              right: 24.w,
            ),
            child: Row(
              textDirection: ui.TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartButton(),
                const Spacer(),
                SizedBox(
                  width: 235.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr('home.store_name'),
                        textDirection: ui.TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        textDirection: ui.TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              context.tr('home.address'),
                              textDirection: ui.TextDirection.rtl,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 25.sp,
                    color: const Color(0xFFFFC13D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    required this.onSearchChanged,
    this.onSearchSubmitted,
    this.onTap,
    super.key,
  });

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 6.h),
    child: Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: ui.TextDirection.ltr,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.tune_rounded,
              color: const Color(0xFF858585),
              size: 23.sp,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 4,
            child: TextField(
              key: const ValueKey('home-search'),
              textAlign: TextAlign.right,
              readOnly: onTap != null,
              showCursor: onTap == null,
              onTap: onTap,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: context.tr('home.search_hint'),
                hintStyle: TextStyle(
                  color: const Color(0xFFB6B6B6),
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 14.w),
              child: Icon(
                Icons.search_rounded,
                color: const Color(0xFF9B9B9B),
                size: 27.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  const HomeHeaderDelegate();

  @override
  double get minExtent => 145.h;

  @override
  double get maxExtent => 145.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => const HomeHeader();

  @override
  bool shouldRebuild(covariant HomeHeaderDelegate oldDelegate) => false;
}

class _CartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) =>
          previous.cart?.itemsCount != current.cart?.itemsCount,
      builder: (context, state) => InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, Routes.cart);
          if (context.mounted) {
            await context.read<CartCubit>().loadCart(force: true);
          }
        },
        borderRadius: BorderRadius.circular(21.r),
        child: SizedBox(
          width: 42.w,
          height: 42.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 28.sp,
                  color: const Color(0xFFFFC13D),
                ),
              ),
              if ((state.cart?.itemsCount ?? 0) > 0)
                Positioned(
                  right: 0,
                  top: -5.h,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D56),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      (state.cart!.itemsCount > 99)
                          ? '99+'
                          : '${state.cart!.itemsCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
