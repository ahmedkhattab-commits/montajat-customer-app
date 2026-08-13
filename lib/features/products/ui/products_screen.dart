import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/products/data/models/product_listing_item.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/logic/products_cubit.dart';
import 'package:montajat_customer_app/features/products/logic/products_state.dart';
import 'package:montajat_customer_app/features/products/ui/widgets/product_listing_card.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/features/profile/data/repositories/profile_repository.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_cubit.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_state.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({required this.arguments, super.key});

  final ProductsScreenArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('products-screen'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70.h,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          arguments.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: const _OrderSummary(),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) => Column(
          children: [
            _ViewToolbar(layout: state.layout),
            Expanded(child: _ProductsContent(state: state)),
          ],
        ),
      ),
    );
  }
}

class _ViewToolbar extends StatelessWidget {
  const _ViewToolbar({required this.layout});

  final ProductsLayout layout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 9.h, 20.w, 10.h),
      child: Row(
        children: [
          const Spacer(),
          _LayoutButton(
            key: const ValueKey('products-list-view'),
            icon: Icons.view_agenda_outlined,
            selected: layout == ProductsLayout.list,
            onTap: () =>
                context.read<ProductsCubit>().changeLayout(ProductsLayout.list),
          ),
          _LayoutButton(
            key: const ValueKey('products-grid-view'),
            icon: Icons.grid_view_rounded,
            selected: layout == ProductsLayout.grid,
            onTap: () =>
                context.read<ProductsCubit>().changeLayout(ProductsLayout.grid),
          ),
        ],
      ),
    );
  }
}

class _LayoutButton extends StatelessWidget {
  const _LayoutButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 42.w,
        height: 35.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4B638) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: selected ? Colors.white : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}

class _ProductsContent extends StatelessWidget {
  const _ProductsContent({required this.state});

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadStatus == ProductsLoadStatus.initial ||
        state.loadStatus == ProductsLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadStatus == ProductsLoadStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr(state.errorMessageKey ?? 'auth_errors.request_failed'),
              textAlign: TextAlign.center,
            ),
            IconButton(
              onPressed: context.read<ProductsCubit>().loadProducts,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      );
    }
    if (state.products.isEmpty) {
      return Center(child: Text(context.tr('products_listing.empty')));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300) {
          context.read<ProductsCubit>().loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.onboardingPrimary,
        onRefresh: context.read<ProductsCubit>().refreshProducts,
        child: state.layout == ProductsLayout.grid
            ? _ProductsGrid(
                products: state.products,
                isLoadingMore: state.isLoadingMore,
              )
            : _ProductsList(
                products: state.products,
                isLoadingMore: state.isLoadingMore,
              ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({required this.products, required this.isLoadingMore});

  final List<ProductListingItem> products;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('products-grid'),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
      itemCount: products.length + (isLoadingMore ? 2 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (_, index) {
        if (index >= products.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ProductListingCard(product: products[index], isGrid: true);
      },
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.products, required this.isLoadingMore});

  final List<ProductListingItem> products;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('products-list'),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, index) {
        if (index >= products.length) {
          return SizedBox(
            height: 60.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return SizedBox(
          height: 180.h,
          child: ProductListingCard(product: products[index], isGrid: false),
        );
      },
    );
  }
}

class _OrderSummary extends StatefulWidget {
  const _OrderSummary();

  @override
  State<_OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<_OrderSummary> {
  late final Future<ProfileModel> _profile = getIt<ProfileRepository>()
      .getProfile();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 92.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: Colors.white,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.onboardingPrimary),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('products_listing.create_order'),
                    style: TextStyle(
                      color: const Color(0xFF9A9A9A),
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11.sp,
                    ),
                  ),
                  FutureBuilder(
                    future: _profile,
                    builder: (context, snapshot) => Text(
                      snapshot.data?.name ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 170.w,
              height: 48.h,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, Routes.cart),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.onboardingPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                child: BlocBuilder<CartCubit, CartState>(
                  buildWhen: (previous, current) =>
                      previous.cart?.itemsCount != current.cart?.itemsCount,
                  builder: (context, state) => Text(
                    context.tr(
                      'products_listing.complete_order',
                      namedArgs: {'count': '${state.cart?.itemsCount ?? 0}'},
                    ),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11.sp,
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
