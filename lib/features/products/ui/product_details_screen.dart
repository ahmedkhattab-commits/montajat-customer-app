import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/cart/ui/widgets/add_to_cart_button.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_arguments.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_model.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_cubit.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_state.dart';
import 'package:montajat_customer_app/features/products/ui/widgets/product_listing_card.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({required this.arguments, super.key});

  final ProductDetailsArguments arguments;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('product-details-screen'),
    backgroundColor: Colors.white,
    appBar: AppBar(
      toolbarHeight: 72.h,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: const BackButton(),
      title: Text(
        context.tr('product_details.title'),
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          key: const ValueKey('product-details-cart'),
          onPressed: () => Navigator.pushNamed(context, Routes.cart),
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.onboardingPrimary,
          ),
        ),
        SizedBox(width: 8.w),
      ],
    ),
    body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        if (state.loadStatus == ProductDetailsLoadStatus.initial ||
            state.loadStatus == ProductDetailsLoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.loadStatus == ProductDetailsLoadStatus.failure ||
            state.details == null) {
          return _ErrorView(messageKey: state.errorMessageKey);
        }
        return _DetailsContent(state: state);
      },
    ),
    bottomNavigationBar: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        final details = state.details;
        if (details == null) return const SizedBox.shrink();
        return _AddToCartBar(details: details, quantity: state.quantity);
      },
    ),
  );
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.state});
  final ProductDetailsState state;

  @override
  Widget build(BuildContext context) {
    final details = state.details!;
    final product = details.product;
    final languageCode = Localizations.localeOf(context).languageCode;
    return RefreshIndicator(
      color: AppColors.onboardingPrimary,
      onRefresh: context.read<ProductDetailsCubit>().loadDetails,
      child: ListView(
        key: const ValueKey('product-details-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 28.h),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300.h,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: product.imageUrl == null
                      ? const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFFBDBDBD),
                        )
                      : CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.contain,
                          placeholder: (_, _) =>
                              const ColoredBox(color: Color(0xFFF7F7F7)),
                          errorWidget: (_, _, _) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                ),
                SizedBox(height: 18.h),
                Text(
                  product.localizedName(languageCode),
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 20.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _StatusBadge(
                      text: product.localizedAvailability(languageCode),
                      isAvailable: product.isAvailable,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      product.itemCode,
                      style: TextStyle(
                        color: const Color(0xFF929292),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Text(
                  product.price == null
                      ? context.tr('products_listing.price_unavailable')
                      : '${product.price!.toStringAsFixed(2)} ${product.currency}',
                  style: TextStyle(
                    color: AppColors.onboardingPrimary,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (details.unitPrice != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '${context.tr('product_details.before_vat')}: '
                    '${details.unitPrice!.toStringAsFixed(2)} ${product.currency}',
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12.sp,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                _InfoCard(details: details),
              ],
            ),
          ),
          _ProductsSection(
            titleKey: 'product_details.you_may_also_like',
            products: state.relatedProducts,
          ),
          _ProductsSection(
            titleKey: 'product_details.recommended_for_you',
            products: state.suggestedProducts,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.details});
  final ProductDetailsModel details;

  @override
  Widget build(BuildContext context) {
    final product = details.product;
    final rows = <(String, String?)>[
      (context.tr('product_details.barcode'), details.barcode),
      (context.tr('product_details.brand'), details.brandCode),
      (context.tr('product_details.department'), details.department),
      (context.tr('product_details.category'), details.category),
      (context.tr('product_details.product_type'), details.productType),
      (context.tr('product_details.animal'), details.animal),
      (context.tr('product_details.uom'), product.uom),
      (
        context.tr('product_details.units_per_carton'),
        product.unitsPerCarton?.toString(),
      ),
    ].where((row) => row.$2?.trim().isNotEmpty == true).toList();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('product_details.information'),
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          for (var index = 0; index < rows.length; index++) ...[
            _InfoRow(label: rows[index].$1, value: rows[index].$2!),
            if (index != rows.length - 1)
              const Divider(height: 18, color: Color(0xFFEEEEEE)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: const Color(0xFF888888), fontSize: 12.sp),
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.isAvailable});
  final String text;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: isAvailable ? const Color(0xFFEAF8F0) : const Color(0xFFFFF2F2),
      borderRadius: BorderRadius.circular(5.r),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: isAvailable ? const Color(0xFF259B62) : const Color(0xFFE95353),
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.titleKey, required this.products});
  final String titleKey;
  final List<ProductListingItem> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr(titleKey),
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  context.tr('home.show_all'),
                  style: TextStyle(
                    color: const Color(0xFFAAAAAA),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 282.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (_, index) => SizedBox(
                width: 178.w,
                child: ProductListingCard(
                  product: products[index],
                  isGrid: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.details, required this.quantity});
  final ProductDetailsModel details;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final canOrder = details.product.isAvailable && !details.isDiscontinued;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 14,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E2E2)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('product-quantity-plus'),
                    onPressed: canOrder
                        ? context.read<ProductDetailsCubit>().incrementQuantity
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                  Text(
                    '$quantity',
                    key: const ValueKey('product-quantity'),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('product-quantity-minus'),
                    onPressed: quantity > 1
                        ? context.read<ProductDetailsCubit>().decrementQuantity
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: AddToCartButton(
                  key: const ValueKey('product-details-add-to-cart'),
                  itemCode: details.product.itemCode,
                  quantity: quantity,
                  enabled: canOrder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.messageKey});
  final String? messageKey;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(messageKey ?? 'auth_errors.request_failed')),
        IconButton(
          onPressed: context.read<ProductDetailsCubit>().loadDetails,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
  );
}
