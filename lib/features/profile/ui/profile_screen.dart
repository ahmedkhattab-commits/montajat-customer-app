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
    _ProfileMenuItem('profile.points', Icons.stars_outlined),
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
    _ProfileMenuItem('profile.reports', Icons.bar_chart_rounded),
    _ProfileMenuItem(
      'profile.financial',
      Icons.account_balance_wallet_outlined,
      Routes.finance,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('profile-screen'),
    backgroundColor: const Color(0xFFF8F8F8),
    bottomNavigationBar: const HomeBottomNavigation(currentIndex: 4),
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
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverGrid.builder(
            itemCount: ProfileScreen._menuItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.02,
            ),
            itemBuilder: (_, index) => _MenuCard(
              item: ProfileScreen._menuItems[index],
              profile: profile,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 14.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: OutlinedButton.icon(
              key: const ValueKey('profile-logout'),
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.tr('profile.logout')),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD94B4B),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0x33D94B4B)),
                minimumSize: Size.fromHeight(54.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
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
    padding: EdgeInsets.fromLTRB(20.w, 58.h, 20.w, 22.h),
    decoration: BoxDecoration(
      color: AppColors.onboardingPrimary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18.r)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 33.r,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.onboardingPrimary,
                size: 38.sp,
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
                      fontSize: 18.sp,
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
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 22.h),
        Row(
          children: [
            const Expanded(
              child: _SummaryCard(
                icon: Icons.stars_rounded,
                value: '--',
                labelKey: 'profile.points_balance',
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: _SummaryCard(
                icon: Icons.location_on_outlined,
                value: '${profile.addressCount}',
                labelKey: 'profile.addresses',
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet_outlined,
                value: profile.canViewFinancials
                    ? '${profile.credit.currentBalance} ${profile.credit.currency}'
                    : '--',
                labelKey: 'profile.balance',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.labelKey,
  });
  final IconData icon;
  final String value;
  final String labelKey;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFFF5B335), size: 25.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 2.h),
        Text(
          context.tr(labelKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: const Color(0xFF888888), fontSize: 10.sp),
        ),
      ],
    ),
  );
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.profile});
  final _ProfileMenuItem item;
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.r),
    elevation: .6,
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
      borderRadius: BorderRadius.circular(8.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: const Color(0xFFF5B335), size: 31.sp),
          SizedBox(height: 10.h),
          Text(
            context.tr(item.labelKey),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
