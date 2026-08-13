import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({required this.profile, super.key});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) => _DetailsPage(
    titleKey: 'profile.my_profile',
    icon: Icons.person_outline_rounded,
    rows: [
      ('profile.account_name', profile.accountName),
      ('profile.mobile', profile.mobile),
      ('profile.email', profile.email ?? '-'),
      ('profile.role', profile.role),
      ('profile.customer_code', profile.cardCode),
      ('profile.city', profile.city ?? '-'),
      ('profile.country', profile.country ?? '-'),
    ],
  );
}

class CreditDetailsScreen extends StatelessWidget {
  const CreditDetailsScreen({required this.credit, super.key});

  final CreditModel credit;

  @override
  Widget build(BuildContext context) {
    String money(num? value) =>
        value == null ? '-' : '$value ${credit.currency}';

    return _DetailsPage(
      titleKey: 'profile.credit_details',
      icon: Icons.account_balance_wallet_outlined,
      rows: [
        ('profile.credit_limit', money(credit.limit)),
        ('profile.credit_used', money(credit.used)),
        ('profile.credit_available', money(credit.available)),
        ('profile.current_balance', money(credit.currentBalance)),
        ('profile.open_orders_balance', money(credit.openOrdersBalance)),
        (
          'profile.credit_status',
          context.tr(
            credit.isExceeded
                ? 'profile.credit_exceeded'
                : 'profile.credit_available_status',
          ),
        ),
      ],
    );
  }
}

class _DetailsPage extends StatelessWidget {
  const _DetailsPage({
    required this.titleKey,
    required this.icon,
    required this.rows,
  });

  final String titleKey;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: Text(
        context.tr(titleKey),
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 28.h),
        children: [
          Container(
            width: 82.w,
            height: 82.w,
            margin: EdgeInsets.symmetric(horizontal: 142.w),
            decoration: BoxDecoration(
              color: AppColors.onboardingPrimary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.onboardingPrimary, size: 40.sp),
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0x16000000)),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _DetailsRow(
                    label: context.tr(rows[index].$1),
                    value: rows[index].$2,
                  ),
                  if (index != rows.length - 1)
                    const Divider(height: 1, color: Color(0x12000000)),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: const Color(0xFF888888), fontSize: 13.sp),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
