import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({required this.currentIndex, super.key});

  final int currentIndex;

  static const _items = [
    _NavigationItem('home.navigation.home', Icons.home_rounded),
    _NavigationItem('home.navigation.categories', Icons.grid_view_rounded),
    _NavigationItem('home.navigation.cart', Icons.shopping_cart_rounded),
    _NavigationItem('home.navigation.orders', Icons.receipt_long_rounded),
    _NavigationItem('home.navigation.more', Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          key: const ValueKey('home-bottom-navigation'),
          height: 72.h,
          child: Row(
            children: List.generate(
              _items.length,
              (index) => Expanded(
                child: _NavigationButton(
                  item: _items[index],
                  selected: currentIndex == index,
                  onTap: () => _navigate(context, index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    final route = switch (index) {
      0 => Routes.home,
      1 => Routes.categories,
      2 => Routes.cart,
      3 => Routes.orders,
      4 => Routes.profile,
      _ => null,
    };

    if (route != null) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.onboardingPrimary
        : const Color(0xFFB9B9B9);

    return InkWell(
      key: ValueKey('home-navigation-${item.labelKey}'),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFDDE9F8) : Colors.transparent,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(item.icon, size: 21.sp, color: color),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr(item.labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.labelKey, this.icon);

  final String labelKey;
  final IconData icon;
}
