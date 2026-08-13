import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/logic/brands_cubit.dart';
import 'package:montajat_customer_app/features/home/logic/brands_state.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/brand_card.dart';

class BrandsScreenArguments {
  const BrandsScreenArguments({required this.title});

  final String title;
}

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({required this.arguments, super.key});

  final BrandsScreenArguments arguments;

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_loadNextPage);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_loadNextPage)
      ..dispose();
    super.dispose();
  }

  void _loadNextPage() {
    if (_controller.hasClients && _controller.position.extentAfter < 320) {
      context.read<BrandsCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('brands-screen'),
    backgroundColor: Colors.white,
    appBar: AppBar(
      toolbarHeight: 74.h,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: const BackButton(),
      title: Text(
        widget.arguments.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: BlocBuilder<BrandsCubit, BrandsState>(
      builder: (context, state) => RefreshIndicator(
        color: const Color(0xFF4F86C6),
        onRefresh: context.read<BrandsCubit>().refreshBrands,
        child: _content(context, state),
      ),
    ),
  );

  Widget _content(BuildContext context, BrandsState state) {
    if (state.loadStatus == BrandsLoadStatus.initial ||
        state.loadStatus == BrandsLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadStatus == BrandsLoadStatus.failure) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 260.h),
          Center(
            child: Column(
              children: [
                Text(
                  context.tr(
                    state.errorMessageKey ?? 'auth_errors.request_failed',
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  onPressed: context.read<BrandsCubit>().loadBrands,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (state.brands.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 260.h),
          Center(child: Text(context.tr('brands.empty'))),
        ],
      );
    }

    return GridView.builder(
      controller: _controller,
      key: const ValueKey('all-brands-grid'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 30.h),
      itemCount: state.visibleBrands.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 120 / 90,
      ),
      itemBuilder: (_, index) => BrandCard(
        brand: state.visibleBrands[index],
        keyPrefix: 'all-brand-products',
      ),
    );
  }
}
