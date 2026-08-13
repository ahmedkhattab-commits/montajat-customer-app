import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/categories/logic/categories_cubit.dart';
import 'package:montajat_customer_app/features/categories/logic/categories_state.dart';
import 'package:montajat_customer_app/features/categories/ui/widgets/categories_shimmer.dart';
import 'package:montajat_customer_app/features/categories/ui/widgets/category_grid.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_header.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({this.standalone = false, super.key});

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    if (standalone) {
      return const _StandaloneCategoriesScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNavigation(currentIndex: 1),
      body: Column(
        children: [
          const HomeHeader(),
          HomeSearchBar(
            onSearchChanged: (query) =>
                context.read<CategoriesCubit>().searchChanged(context, query),
          ),
          Expanded(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) => RefreshIndicator(
                color: const Color(0xFF4F86C6),
                onRefresh: context.read<CategoriesCubit>().refreshCategories,
                child: CustomScrollView(
                  key: const ValueKey('categories-scroll'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: 15.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        child: Text(
                          context.tr('categories.title'),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                    ..._categoryContent(context, state),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandaloneCategoriesScreen extends StatelessWidget {
  const _StandaloneCategoriesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('standalone-categories-screen'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 82.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          context.tr('categories.title'),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) => RefreshIndicator(
          color: const Color(0xFF4F86C6),
          onRefresh: context.read<CategoriesCubit>().refreshCategories,
          child: CustomScrollView(
            key: const ValueKey('categories-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 12.h),
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: TextField(
                      key: const ValueKey('categories-page-search'),
                      textAlign: TextAlign.start,
                      onChanged: (query) => context
                          .read<CategoriesCubit>()
                          .searchChanged(context, query),
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13.sp,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: context.tr('categories.search_hint'),
                        hintStyle: TextStyle(
                          color: const Color(0xFFB9B9B9),
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 13.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF9D9D9D),
                          size: 25.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 17.h),
                      ),
                    ),
                  ),
                ),
              ),
              ..._categoryContent(context, state),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _categoryContent(BuildContext context, CategoriesState state) {
  if (state.loadStatus == CategoriesLoadStatus.initial ||
      state.loadStatus == CategoriesLoadStatus.loading) {
    return const [CategoriesShimmer()];
  }
  if (state.loadStatus == CategoriesLoadStatus.failure) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
                onPressed: context.read<CategoriesCubit>().loadCategories,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      ),
    ];
  }
  return [CategoryGrid(categories: state.visibleCategories)];
}
