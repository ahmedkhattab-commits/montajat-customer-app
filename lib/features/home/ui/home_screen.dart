import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';
import 'package:montajat_customer_app/features/home/data/models/home_product_model.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_brands.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_category_strip.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_header.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_offers.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_product_section.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _products = [
    HomeProductModel(
      nameKey: 'home.products.eye_cleaner',
      quantityKey: 'home.products.six_units',
      imageAsset: ImageAsset.homeEyeCleaner,
      price: '150',
    ),
    HomeProductModel(
      nameKey: 'home.products.bird_food',
      quantityKey: 'home.products.twelve_units',
      imageAsset: ImageAsset.homeBirdFood,
      price: '150',
    ),
    HomeProductModel(
      nameKey: 'home.products.eye_cleaner',
      quantityKey: 'home.products.six_units',
      imageAsset: ImageAsset.homeEyeCleaner,
      price: '150',
      available: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNavigation(currentIndex: 0),
      body: CustomScrollView(
        key: const ValueKey('home-scroll'),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeHeaderDelegate(
              onSearchChanged: context.read<HomeCubit>().searchChanged,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          SliverToBoxAdapter(
            child: SizedBox(
              key: const ValueKey('home-promo-slider'),
              height: 108.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (_, index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: SizedBox(
                    width: 378.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        ImageAsset.homeHero,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              titleKey: 'home.categories_title',
              onShowAll: () => Navigator.of(
                context,
              ).pushNamed(Routes.categories, arguments: true),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          SliverToBoxAdapter(
            child: HomeCategoryStrip(
              categories: CategoriesRepository.homeItems,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          const SliverToBoxAdapter(child: HomeNewArrivalsBrands()),
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          const SliverToBoxAdapter(
            child: HomeProductSection(
              titleKey: 'home.latest_products',
              products: _products,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          const SliverToBoxAdapter(child: HomeBrands()),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          const SliverToBoxAdapter(
            child: HomeProductSection(
              titleKey: 'home.featured_products',
              products: _products,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          const SliverToBoxAdapter(child: HomeOffers()),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          const SliverToBoxAdapter(
            child: HomeProductSection(
              titleKey: 'home.latest_products',
              products: _products,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 22.h)),
          const SliverToBoxAdapter(
            child: HomeSectionHeader(titleKey: 'home.shop_by_category'),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          SliverToBoxAdapter(child: _CategoryColors()),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          const SliverToBoxAdapter(
            child: HomeProductSection(
              titleKey: 'home.latest_products',
              products: _products,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 35.h)),
        ],
      ),
    );
  }
}

class _CategoryColors extends StatelessWidget {
  const _CategoryColors();

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFFFB500),
      Color(0xFFF6BB3B),
      Color(0xFFE94C40),
      Color(0xFF00A8F3),
    ];

    return SizedBox(
      height: 84.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, _) => SizedBox(width: 9.w),
        itemBuilder: (_, index) => Container(
          width: 84.w,
          decoration: BoxDecoration(
            color: colors[index],
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Icon(
            Icons.pets_outlined,
            size: 48.sp,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}
