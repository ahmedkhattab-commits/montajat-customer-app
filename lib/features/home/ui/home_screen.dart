import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';
import 'package:montajat_customer_app/features/home/logic/home_state.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_api_sections.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_header.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_shimmer.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNavigation(currentIndex: 4),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => RefreshIndicator(
          color: const Color(0xFF4F86C6),
          backgroundColor: Colors.white,
          onRefresh: context.read<HomeCubit>().refreshHome,
          child: CustomScrollView(
            key: const ValueKey('home-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: const HomeHeaderDelegate(),
              ),
              SliverToBoxAdapter(
                child: HomeSearchBar(
                  onSearchChanged: (_) {},
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.products,
                      arguments: ProductsScreenArguments(
                        source: ProductsFilterSource.all,
                        filterValue: '',
                        title: context.tr('products_listing.search_results'),
                        initialQuery: '',
                      ),
                    );
                  },
                ),
              ),
              if (state.loadStatus == HomeLoadStatus.initial ||
                  state.loadStatus == HomeLoadStatus.loading)
                const SliverToBoxAdapter(child: HomeShimmer())
              else if (state.loadStatus == HomeLoadStatus.failure)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr(
                              state.errorMessageKey ??
                                  'auth_errors.request_failed',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          IconButton(
                            onPressed: context.read<HomeCubit>().loadHome,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (state.home == null || state.home!.sections.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Icon(Icons.inventory_2_outlined)),
                )
              else ...[
                SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                for (final section in state.home!.sections) ...[
                  if (section.key == 'offers_for_you') ...[
                    if (state.home!.expiryOffers.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: HomeExpiryOffersSection(
                          section: section,
                          offers: state.home!.expiryOffers,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 18.h)),
                    ],
                  ] else ...[
                    SliverToBoxAdapter(child: HomeApiSection(section: section)),
                    SliverToBoxAdapter(child: SizedBox(height: 18.h)),
                  ],
                ],
                SliverToBoxAdapter(child: SizedBox(height: 17.h)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
