import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/addresses/data/models/address_model.dart';
import 'package:montajat_customer_app/features/addresses/logic/addresses_cubit.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('addresses-screen'),
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      toolbarHeight: 76.h,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      title: Text(
        context.tr('addresses.title'),
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      ),
    ),
    body: BlocConsumer<AddressesCubit, AddressesState>(
      listenWhen: (previous, current) =>
          previous.errorMessageKey != current.errorMessageKey &&
          current.errorMessageKey != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(state.errorMessageKey!))),
      ),
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessageKey != null && state.addresses.isEmpty) {
          return _ErrorView(
            messageKey: state.errorMessageKey!,
            onRetry: context.read<AddressesCubit>().loadAddresses,
          );
        }
        if (state.addresses.isEmpty) return const _EmptyAddresses();
        return RefreshIndicator(
          color: AppColors.onboardingPrimary,
          onRefresh: context.read<AddressesCubit>().loadAddresses,
          child: ListView.separated(
            key: const ValueKey('addresses-list'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
            itemCount: state.addresses.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, index) =>
                _AddressCard(address: state.addresses[index]),
          ),
        );
      },
    ),
  );
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final AddressModel address;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 1,
    shadowColor: const Color(0x18000000),
    borderRadius: BorderRadius.circular(10.r),
    child: InkWell(
      key: ValueKey('address-${address.id}'),
      onTap: () async {
        await Navigator.of(
          context,
        ).pushNamed(Routes.addressDetails, arguments: address.id);
        if (context.mounted) context.read<AddressesCubit>().loadAddresses();
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: const Color(0xFFFFF5DC),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFF5B335),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.label,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (address.isPreferred) const _PreferredBadge(),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      Text(
                        address.formatted ?? _fallbackAddress(address),
                        style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 12.sp,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: const Color(0xFFB0B0B0),
                ),
              ],
            ),
            SizedBox(height: 13.h),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (address.typeLabel != null)
                  _InfoChip(
                    icon: Icons.local_shipping_outlined,
                    text: address.typeLabel!,
                  ),
                const Spacer(),
                if (!address.isPreferred)
                  BlocBuilder<AddressesCubit, AddressesState>(
                    buildWhen: (previous, current) =>
                        previous.preferredAddressId !=
                        current.preferredAddressId,
                    builder: (context, state) => TextButton.icon(
                      key: ValueKey('prefer-address-${address.id}'),
                      onPressed: state.preferredAddressId == null
                          ? () => context.read<AddressesCubit>().setPreferred(
                              address.id,
                            )
                          : null,
                      icon: state.preferredAddressId == address.id
                          ? SizedBox.square(
                              dimension: 17.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 19),
                      label: Text(context.tr('addresses.make_preferred')),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  String _fallbackAddress(AddressModel value) => [
    value.buildingNumber,
    value.street,
    value.district,
    value.city,
    value.state,
  ].whereType<String>().join('، ');
}

class _PreferredBadge extends StatelessWidget {
  const _PreferredBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF2FC),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      context.tr('addresses.preferred'),
      style: TextStyle(
        color: AppColors.onboardingPrimary,
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17.sp, color: const Color(0xFF888888)),
      SizedBox(width: 5.w),
      Text(
        text,
        style: TextStyle(color: const Color(0xFF777777), fontSize: 11.sp),
      ),
    ],
  );
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: context.read<AddressesCubit>().loadAddresses,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 220.h),
        Icon(
          Icons.location_off_outlined,
          color: const Color(0xFFBDBDBD),
          size: 58.sp,
        ),
        SizedBox(height: 12.h),
        Text(context.tr('addresses.empty'), textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.messageKey, required this.onRetry});
  final String messageKey;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(messageKey), textAlign: TextAlign.center),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
  );
}
