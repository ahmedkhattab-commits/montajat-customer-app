import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/returns/logic/returns_cubit.dart';

class ReturnDetailsScreen extends StatelessWidget {
  const ReturnDetailsScreen({required this.reference, super.key});
  final String reference;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      title: Text(context.tr('returns.details')),
      centerTitle: true,
      backgroundColor: Colors.white,
    ),
    body: BlocBuilder<ReturnsCubit, ReturnsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = state.details;
        if (item == null) {
          return Center(
            child: Text(context.tr(state.error ?? 'returns.not_found')),
          );
        }
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColors.onboardingPrimary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_return_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    item.reference,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.status,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _Info(context.tr('returns.order'), item.orderNumber),
            if (item.reason != null)
              _Info(context.tr('returns.reason'), item.reason!),
            if (item.notes != null)
              _Info(context.tr('returns.notes'), item.notes!),
            SizedBox(height: 18.h),
            Text(
              context.tr('returns.products'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
            ),
            SizedBox(height: 10.h),
            ...item.lines.map(
              (line) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            line.itemCode,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${context.tr('returns.quantity')}: ${line.quantity}',
                      style: const TextStyle(
                        color: AppColors.onboardingPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}
