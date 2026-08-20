import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_arguments.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/cart/ui/widgets/add_to_cart_button.dart';

class ProductListingCard extends StatelessWidget {
  const ProductListingCard({
    required this.product,
    required this.isGrid,
    super.key,
  });

  final ProductListingItem product;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFECECEC)),
        borderRadius: BorderRadius.circular(5.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('product-card-${product.itemCode}'),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.productDetails,
          arguments: ProductDetailsArguments(itemCode: product.itemCode),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
          child: isGrid
              ? _GridContent(product: product, languageCode: languageCode)
              : _ListContent(product: product, languageCode: languageCode),
        ),
      ),
    );
  }
}

class _GridContent extends StatelessWidget {
  const _GridContent({required this.product, required this.languageCode});

  final ProductListingItem product;
  final String languageCode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: Center(
          child: product.imageUrl == null
              ? _ImageFallback(size: 42.sp)
              : CachedNetworkImage(
                  imageUrl: product.imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      const ColoredBox(color: Color(0xFFF8F8F8)),
                  errorWidget: (_, _, _) => _ImageFallback(size: 42.sp),
                ),
        ),
      ),
      Text(
        product.localizedName(languageCode),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 12.sp,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 7.h),
      Row(
        children: [
          Text(
            product.price == null
                ? context.tr('products_listing.price_unavailable')
                : '${product.price!.toStringAsFixed(2)} ${product.currency}',
            style: TextStyle(
              color: const Color(0xFFFF5151),
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _packageText(context, product),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF949494),
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),
      SizedBox(
        height: 38.h,
        child: AddToCartButton(
          itemCode: product.itemCode,
          enabled: product.isAvailable,
        ),
      ),
    ],
  );
}

class _ListContent extends StatelessWidget {
  const _ListContent({required this.product, required this.languageCode});

  final ProductListingItem product;
  final String languageCode;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        width: 112.w,
        child: Center(
          child: product.imageUrl == null
              ? _ImageFallback(size: 40.sp)
              : CachedNetworkImage(
                  imageUrl: product.imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      const ColoredBox(color: Color(0xFFF8F8F8)),
                  errorWidget: (_, _, _) => _ImageFallback(size: 40.sp),
                ),
        ),
      ),
      SizedBox(width: 14.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              product.localizedName(languageCode),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13.sp,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              _packageText(context, product),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF949494),
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 10.sp,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              product.price == null
                  ? context.tr('products_listing.price_unavailable')
                  : '${product.price!.toStringAsFixed(2)} ${product.currency}',
              style: TextStyle(
                color: const Color(0xFFFF5151),
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 38.h,
              child: AddToCartButton(
                itemCode: product.itemCode,
                enabled: product.isAvailable,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

String _packageText(BuildContext context, ProductListingItem product) {
  final units = product.unitsPerCarton;
  if (units != null) {
    return context.tr(
      'products_listing.units_per_carton',
      namedArgs: {'count': units.toString()},
    );
  }
  return product.uom.isEmpty ? product.itemCode : product.uom;
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.image_outlined, size: size, color: const Color(0xFFF0F0F0));
}
