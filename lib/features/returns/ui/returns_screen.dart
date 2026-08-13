import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/returns/logic/returns_cubit.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      title: Text(context.tr('returns.title')),
      centerTitle: true,
      backgroundColor: Colors.white,
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: AppColors.onboardingPrimary,
      foregroundColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, Routes.createReturn).then(
        (_) => context.mounted ? context.read<ReturnsCubit>().load() : null,
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(context.tr('returns.create')),
    ),
    body: BlocBuilder<ReturnsCubit, ReturnsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.items.isEmpty) {
          return _Error(message: state.error!);
        }
        return RefreshIndicator(
          onRefresh: context.read<ReturnsCubit>().load,
          child: state.items.isEmpty
              ? const _Empty()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 100.h),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) {
                    final item = state.items[i];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.returnDetails,
                          arguments: item.reference,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Container(
                                width: 46.r,
                                height: 46.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5DE),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: const Icon(
                                  Icons.assignment_return_outlined,
                                  color: Color(0xFFF5A900),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${context.tr('returns.reference')}: ${item.reference}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      '${context.tr('returns.order')}: ${item.orderNumber}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF2FC),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: AppColors.onboardingPrimary,
                                    fontSize: 11.sp,
                                  ),
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

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: 180.h),
      Icon(
        Icons.assignment_return_outlined,
        size: 90.sp,
        color: const Color(0xFFF5B335),
      ),
      SizedBox(height: 18.h),
      Text(
        context.tr('returns.empty'),
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17.sp),
      ),
    ],
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(message)),
        IconButton(
          onPressed: context.read<ReturnsCubit>().load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );
}
