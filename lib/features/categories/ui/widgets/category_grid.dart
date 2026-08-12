import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({required this.categories, super.key});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            context.tr('categories.empty'),
            style: TextStyle(
              color: const Color(0xFF8B8B8B),
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 15.sp,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(22.w, 8.h, 22.w, 30.h),
      sliver: SliverGrid(
        key: const ValueKey('categories-grid'),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 22.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.67,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _CategoryTile(category: categories[index]),
          childCount: categories.length,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final title = category.labelKey == null
        ? category.value
        : context.tr(category.labelKey!);
    return Column(
      children: [
        InkWell(
          key: ValueKey('category-products-${category.value}'),
          onTap: () => Navigator.of(context).pushNamed(
            Routes.products,
            arguments: ProductsScreenArguments(
              source: ProductsFilterSource.category,
              filterValue: category.value,
              title: title,
            ),
          ),
          borderRadius: BorderRadius.circular(10.r),
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFEFEFE),
                border: Border.all(
                  color: AppColors.languageAccent.withValues(alpha: 0.42),
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                category.icon,
                color: const Color(0xFFFFB629),
                size: 38.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 7.h),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.25,
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
