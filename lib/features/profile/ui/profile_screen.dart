import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';
import 'package:montajat_customer_app/features/profile/logic/profile_cubit.dart';
import 'package:montajat_customer_app/features/profile/logic/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menuItems = [
    _ProfileMenuItem(
      'profile.my_profile',
      Icons.person_outline_rounded,
      null,
      _ProfileMenuAction.profile,
    ),
    _ProfileMenuItem(
      'profile.addresses',
      Icons.location_on_outlined,
      Routes.addresses,
    ),
    _ProfileMenuItem(
      'profile.orders',
      Icons.inventory_2_outlined,
      Routes.orders,
    ),
    _ProfileMenuItem(
      'profile.reports',
      Icons.bar_chart_rounded,
      Routes.reports,
    ),
    _ProfileMenuItem('insights.title', Icons.insights_rounded, Routes.insights),
    _ProfileMenuItem(
      'profile.financial',
      Icons.account_balance_wallet_outlined,
      Routes.finance,
    ),
    _ProfileMenuItem(
      'returns.title',
      Icons.assignment_return_outlined,
      Routes.returns,
    ),
    _ProfileMenuItem('reorder.title', Icons.replay_rounded, Routes.reorder),
    _ProfileMenuItem(
      'notifications.title',
      Icons.notifications_outlined,
      Routes.notifications,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('profile-screen'),
    backgroundColor: const Color(0xFFF8F8F8),
    bottomNavigationBar: const HomeBottomNavigation(currentIndex: 0),
    body: BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileLoadStatus.loading ||
            state.status == ProfileLoadStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.profile == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr(
                    state.errorMessageKey ?? 'auth_errors.request_failed',
                  ),
                ),
                IconButton(
                  onPressed: context.read<ProfileCubit>().loadProfile,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          );
        }
        return _ProfileContent(profile: state.profile!);
      },
    ),
  );
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: context.read<ProfileCubit>().loadProfile,
    child: CustomScrollView(
      key: const ValueKey('profile-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),
        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverToBoxAdapter(
            child: _MenuCard(
              item: ProfileScreen._menuItems.first,
              profile: profile,
              featured: true,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverGrid.builder(
            itemCount: ProfileScreen._menuItems.length - 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.48,
            ),
            itemBuilder: (_, index) => _MenuCard(
              item: ProfileScreen._menuItems[index + 1],
              profile: profile,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 18.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: OutlinedButton.icon(
              key: const ValueKey('profile-logout'),
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.tr('profile.logout')),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD94B4B),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0x33D94B4B)),
                minimumSize: Size.fromHeight(50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    ),
  );

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('profile.logout')),
        content: Text(context.tr('profile.logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('profile.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD94B4B),
            ),
            child: Text(context.tr('profile.logout')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<ProfileCubit>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      20.w,
      MediaQuery.paddingOf(context).top + 18.h,
      20.w,
      24.h,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          AppColors.onboardingPrimary,
          AppColors.onboardingPrimary.withValues(alpha: .9),
        ],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 31.r,
              backgroundColor: Colors.white.withValues(alpha: .96),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.onboardingPrimary,
                size: 34.sp,
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${profile.mobile}  •  ${profile.accountName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
    required this.profile,
    this.featured = false,
  });
  final _ProfileMenuItem item;
  final ProfileModel profile;
  final bool featured;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14.r),
    elevation: 0,
    child: InkWell(
      key: ValueKey('profile-menu-${item.labelKey}'),
      onTap: () {
        if (item.route != null) {
          Navigator.pushNamed(context, item.route!);
          return;
        }
        switch (item.action) {
          case _ProfileMenuAction.profile:
            Navigator.pushNamed(
              context,
              Routes.profileDetails,
              arguments: profile,
            );
          case null:
            return;
        }
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: featured ? 72.h : null,
        padding: EdgeInsets.symmetric(
          horizontal: featured ? 18.w : 12.w,
          vertical: 13.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: featured
            ? Row(
                children: [
                  _MenuIcon(icon: item.icon),
                  SizedBox(width: 14.w),
                  Expanded(child: _MenuLabel(labelKey: item.labelKey)),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15.sp,
                    color: const Color(0xFF9A9A9A),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MenuIcon(icon: item.icon),
                  SizedBox(height: 9.h),
                  _MenuLabel(labelKey: item.labelKey),
                ],
              ),
      ),
    ),
  );
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40.r,
    height: 40.r,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5DE),
      borderRadius: BorderRadius.circular(11.r),
    ),
    child: Icon(icon, color: const Color(0xFFF5A900), size: 23.sp),
  );
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.labelKey});
  final String labelKey;

  @override
  Widget build(BuildContext context) => Text(
    context.tr(labelKey),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.start,
    style: TextStyle(
      color: const Color(0xFF202020),
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _ProfileMenuItem {
  const _ProfileMenuItem(this.labelKey, this.icon, [this.route, this.action]);
  final String labelKey;
  final IconData icon;
  final String? route;
  final _ProfileMenuAction? action;
}

enum _ProfileMenuAction { profile }
