import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';

class BrandCard extends StatelessWidget {
  const BrandCard({
    required this.brand,
    this.keyPrefix = 'brand-products',
    super.key,
  });

  final HomeBrandModel brand;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('$keyPrefix-${brand.code}'),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.products,
        arguments: ProductsScreenArguments(
          source: ProductsFilterSource.brand,
          filterValue: brand.code,
          title: brand.name,
        ),
      ),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: brand.imageUrl.trim().isEmpty
            ? Text(
                brand.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp),
              )
            : CachedNetworkImage(
                imageUrl: brand.imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const ColoredBox(color: Color(0xFFF7F7F7)),
                errorWidget: (_, _, _) => Text(
                  brand.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
      ),
    );
  }
}
