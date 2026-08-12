import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_arguments.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_model.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_cubit.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_state.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({required this.arguments, super.key});

  final ProductDetailsArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state.loadStatus == ProductDetailsLoadStatus.initial ||
              state.loadStatus == ProductDetailsLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.loadStatus == ProductDetailsLoadStatus.failure ||
              state.details == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr(
                      state.errorMessageKey ?? 'auth_errors.request_failed',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    onPressed: context.read<ProductDetailsCubit>().loadDetails,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            );
          }
          return _DetailsContent(details: state.details!);
        },
      ),
      bottomNavigationBar:
          BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
            builder: (context, state) {
              final details = state.details;
              if (state.loadStatus != ProductDetailsLoadStatus.success ||
                  details == null) {
                return const SizedBox.shrink();
              }
              return _AddToCartBar(details: details, quantity: state.quantity);
            },
          ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.details});

  final ProductDetailsModel details;

  @override
  Widget build(BuildContext context) {
    final product = details.product;
    final languageCode = Localizations.localeOf(context).languageCode;
    return RefreshIndicator(
      color: AppColors.onboardingPrimary,
      onRefresh: context.read<ProductDetailsCubit>().loadDetails,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
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
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
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
          style: TextStyle(
            color: const Color(0xFF888888),
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 12.sp,
          ),
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
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
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
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
                child: FilledButton(
                  key: const ValueKey('product-details-add-to-cart'),
                  onPressed: canOrder ? () {} : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.onboardingPrimary,
                    disabledBackgroundColor: const Color(0xFFFFF4D7),
                    disabledForegroundColor: const Color(0xFFE4B532),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  child: Text(
                    context.tr(
                      canOrder ? 'home.add_to_cart' : 'home.unavailable',
                    ),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
