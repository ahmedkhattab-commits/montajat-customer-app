import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/addresses/logic/addresses_cubit.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('addresses-screen'),
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      title: Text(
        context.tr('addresses.title'),
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessageKey != null) {
          return _ErrorView(
            messageKey: state.errorMessageKey!,
            onRetry: context.read<AddressesCubit>().loadAddresses,
          );
        }
        if (state.addresses.isEmpty) {
          return RefreshIndicator(
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
                Text(
                  context.tr('addresses.empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: context.read<AddressesCubit>().loadAddresses,
          child: ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: state.addresses.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, index) {
              final address = state.addresses[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                child: InkWell(
                  key: ValueKey('address-${address.id}'),
                  onTap: () async {
                    await Navigator.of(
                      context,
                    ).pushNamed(Routes.addressDetails, arguments: address.id);
                    if (context.mounted) {
                      context.read<AddressesCubit>().loadAddresses();
                    }
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
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
                                        fontFamily: 'IBMPlexSansArabic',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (address.isPreferred) _PreferredBadge(),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                [
                                  address.street,
                                  address.district,
                                  address.city,
                                ].whereType<String>().join('، '),
                                style: TextStyle(
                                  color: const Color(0xFF777777),
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 12.sp,
                                  height: 1.5,
                                ),
                              ),
                              if (!address.isPreferred) ...[
                                SizedBox(height: 10.h),
                                TextButton(
                                  onPressed: () => context
                                      .read<AddressesCubit>()
                                      .setPreferred(address.id),
                                  child: Text(
                                    context.tr('addresses.make_preferred'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

class _PreferredBadge extends StatelessWidget {
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
