import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/brands_screen.dart';
import 'package:montajat_customer_app/features/home/ui/offers_screen.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/brand_card.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/expiry_offer_banner_card.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_section_header.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_arguments.dart';

class HomeApiSection extends StatelessWidget {
  const HomeApiSection({required this.section, super.key});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return switch (section.type) {
      HomeSectionType.banners =>
        section.key == 'hero_banners'
            ? _BannerSlider(section: section)
            : _BannerSection(section: section),
      HomeSectionType.categories => _CategorySection(section: section),
      HomeSectionType.brands => _BrandSection(section: section),
      HomeSectionType.products => _ProductSection(section: section),
    };
  }
}

class HomeExpiryOffersSection extends StatelessWidget {
  const HomeExpiryOffersSection({
    required this.section,
    required this.offers,
    super.key,
  });

  final HomeSectionModel section;
  final List<HomeExpiryOfferModel> offers;

  @override
  Widget build(BuildContext context) {
    final visibleOffers = offers.take(4).toList(growable: false);
    return Column(
      children: [
        HomeSectionHeader(
          title: _title(context, section),
          actionKey: 'home.offers_for_you',
          onShowAll: () => Navigator.of(context).pushNamed(
            Routes.offers,
            arguments: OffersScreenArguments(offers: offers),
          ),
        ),
        SizedBox(height: 10.h),
        ...List.generate(visibleOffers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 10.h),
            child: ExpiryOfferBannerCard(
              offer: visibleOffers[index],
              index: index,
              keyPrefix: 'home-expiry-offer',
            ),
          );
        }),
      ],
    );
  }
}

class _BannerSlider extends StatelessWidget {
  const _BannerSlider({required this.section});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    final banners = section.items.cast<HomeBannerModel>();
    return SizedBox(
      key: const ValueKey('home-promo-slider'),
      height: 108.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (_, index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: SizedBox(
            width: 378.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: _NetworkImage(
                imageUrl: banners[index].imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.section});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    final banners = section.items.cast<HomeBannerModel>();
    return Column(
      children: [
        HomeSectionHeader(title: _title(context, section)),
        SizedBox(height: 10.h),
        ...banners.map(
          (banner) => Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 10.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: AspectRatio(
                aspectRatio: 380 / 102,
                child: _NetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.section});

  static const _icons = [
    Icons.restaurant_outlined,
    Icons.local_mall_outlined,
    Icons.chair_outlined,
    Icons.toys_outlined,
    Icons.inventory_2_outlined,
    Icons.health_and_safety_outlined,
    Icons.pets_outlined,
    Icons.cleaning_services_outlined,
  ];

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    final categories = section.items.cast<HomeCategoryModel>();
    return Column(
      children: [
        HomeSectionHeader(
          title: _title(context, section),
          actionKey: 'home.categories_title',
          onShowAll: () => Navigator.of(
            context,
          ).pushNamed(Routes.categories, arguments: true),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          key: const ValueKey('home-categories'),
          height: 100.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (_, index) {
              final category = categories[index];
              return InkWell(
                key: ValueKey('home-category-products-${category.value}'),
                onTap: () => Navigator.of(context).pushNamed(
                  Routes.products,
                  arguments: ProductsScreenArguments(
                    source: ProductsFilterSource.category,
                    filterValue: category.value,
                    title: category.value,
                  ),
                ),
                borderRadius: BorderRadius.circular(9.r),
                child: SizedBox(
                  width: 74.w,
                  child: Column(
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.languageAccent.withValues(
                              alpha: 0.55,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                        child: Icon(
                          _icons[index % _icons.length],
                          size: 35.sp,
                          color: const Color(0xFFFFB629),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        category.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection({required this.section});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    final allBrands = section.items.cast<HomeBrandModel>();
    final brands = allBrands.take(6).toList(growable: false);
    return Column(
      key: section.key == 'new_brands'
          ? const ValueKey('home-new-arrivals-brands')
          : null,
      children: [
        HomeSectionHeader(
          title: _title(context, section),
          actionKey: section.key,
          onShowAll: () => Navigator.of(context).pushNamed(
            Routes.brands,
            arguments: BrandsScreenArguments(
              title: _title(context, section),
              brands: allBrands,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: brands.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 120 / 90,
            ),
            itemBuilder: (_, index) => BrandCard(brand: brands[index]),
          ),
        ),
      ],
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.section});

  final HomeSectionModel section;

  @override
  Widget build(BuildContext context) {
    final products = section.items.cast<HomeApiProductModel>();
    return Column(
      children: [
        HomeSectionHeader(
          title: _title(context, section),
          onShowAll: () => Navigator.of(context).pushNamed(
            Routes.products,
            arguments: ProductsScreenArguments(
              source: ProductsFilterSource.all,
              filterValue: '',
              title: _title(context, section),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 278.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (_, index) =>
                _ProductCard(product: products[index], index: index),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.index});

  final HomeApiProductModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return SizedBox(
      width: 174.w,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(5.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('home-product-${product.itemCode}-$index'),
          onTap: () => Navigator.of(context).pushNamed(
            Routes.productDetails,
            arguments: ProductDetailsArguments(itemCode: product.itemCode),
          ),
          child: Padding(
            padding: EdgeInsets.all(7.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: product.imageUrl == null
                      ? const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFFD5D5D5),
                          size: 54,
                        )
                      : _NetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.contain,
                        ),
                ),
                SizedBox(height: 7.h),
                Text(
                  product.localizedName(languageCode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  product.localizedAvailability(languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 10.sp,
                    color: const Color(0xFF8D8D8D),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${product.unitPriceWithVat.toStringAsFixed(2)} ${product.currency}',
                  textAlign: TextAlign.start,
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
                    onPressed: product.canOrder ? () {} : null,
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
                        product.canOrder
                            ? 'home.add_to_cart'
                            : 'home.unavailable',
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
          ),
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.imageUrl, required this.fit});

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (_, _) => const ColoredBox(color: Color(0xFFF3F3F3)),
      errorWidget: (_, _, _) => const ColoredBox(
        color: Color(0xFFF7F7F7),
        child: Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}

String _title(BuildContext context, HomeSectionModel section) =>
    section.localizedTitle(Localizations.localeOf(context).languageCode);
