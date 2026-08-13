import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/cart/ui/widgets/add_to_cart_button.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_arguments.dart';
import 'package:montajat_customer_app/features/reorder/data/models/reorder_product_model.dart';
import 'package:montajat_customer_app/features/reorder/logic/reorder_cubit.dart';

class ReorderScreen extends StatelessWidget {
  const ReorderScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(context.tr('reorder.title')),
        bottom: TabBar(
          indicatorColor: AppColors.onboardingPrimary,
          labelColor: AppColors.onboardingPrimary,
          unselectedLabelColor: const Color(0xFF888888),
          tabs: [
            Tab(text: context.tr('reorder.my_products')),
            Tab(text: context.tr('reorder.due')),
          ],
        ),
      ),
      body: BlocBuilder<ReorderCubit, ReorderState>(
        builder: (context, state) {
          if (state.loading && state.myProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.myProducts.isEmpty) {
            return _Error(message: state.error!);
          }
          return TabBarView(
            children: [
              _ProductList(items: state.myProducts, due: false),
              _ProductList(items: state.dueProducts, due: true),
            ],
          );
        },
      ),
    ),
  );
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.items, required this.due});
  final List<ReorderProductModel> items;
  final bool due;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: context.read<ReorderCubit>().load,
    child: items.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 170.h),
              Icon(
                due ? Icons.update_rounded : Icons.history_rounded,
                size: 86.sp,
                color: const Color(0xFFF5B335),
              ),
              SizedBox(height: 18.h),
              Text(
                context.tr(due ? 'reorder.empty_due' : 'reorder.empty'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
            ],
          )
        : ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 28.h),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, index) =>
                _ReorderCard(product: items[index], showDue: due),
          ),
  );
}

class _ReorderCard extends StatelessWidget {
  const _ReorderCard({required this.product, required this.showDue});
  final ReorderProductModel product;
  final bool showDue;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => Navigator.pushNamed(
          context,
          Routes.productDetails,
          arguments: ProductDetailsArguments(itemCode: product.itemCode),
        ),
        child: Padding(
          padding: EdgeInsets.all(13.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88.w,
                height: 94.h,
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: product.imageUrl == null
                    ? const Icon(Icons.image_outlined, color: Color(0xFFDADADA))
                    : CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const Icon(
                          Icons.image_outlined,
                          color: Color(0xFFDADADA),
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.localizedName(locale),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      product.itemCode,
                      style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                    ),
                    if (showDue) ...[
                      SizedBox(height: 6.h),
                      Text(
                        context.tr(
                          product.isOverdue
                              ? 'reorder.overdue'
                              : 'reorder.due_soon',
                        ),
                        style: TextStyle(
                          color: product.isOverdue
                              ? const Color(0xFFE95353)
                              : const Color(0xFFF5A900),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.price == null
                                ? '-'
                                : '${product.price!.toStringAsFixed(2)} ${product.currency}',
                            style: TextStyle(
                              color: const Color(0xFFE95353),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 112.w,
                          height: 38.h,
                          child: AddToCartButton(
                            itemCode: product.itemCode,
                            quantity: product.lastQuantity ?? 1,
                            enabled: product.canOrder,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(message)),
        IconButton(
          onPressed: context.read<ReorderCubit>().load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );
}
