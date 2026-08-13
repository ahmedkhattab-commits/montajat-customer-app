import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/finance/logic/finance_cubit.dart';

class FinanceInvoiceDetailsScreen extends StatelessWidget {
  const FinanceInvoiceDetailsScreen({required this.docNum, super.key});
  final String docNum;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      toolbarHeight: 72.h,
      title: Text(
        context.tr('finance.invoice_details'),
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      ),
    ),
    body: BlocBuilder<InvoiceDetailsCubit, dynamic>(
      builder: (context, invoice) {
        if (invoice == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.all(18.w),
          children: [
            Container(
              padding: EdgeInsets.all(17.w),
              decoration: BoxDecoration(
                color: AppColors.onboardingPrimary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: Colors.white),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      invoice.invoice.number,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${invoice.invoice.amount.toStringAsFixed(2)} ${invoice.invoice.currency.toUpperCase() == 'SAR' ? context.tr('finance.sar') : invoice.invoice.currency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _Box(
              children: [
                _Row(
                  context.tr('finance.document_number'),
                  invoice.invoice.number,
                ),
                _Row(context.tr('finance.status'), invoice.invoice.status),
                _Row(
                  context.tr('finance.total'),
                  '${invoice.invoice.amount.toStringAsFixed(2)} ${invoice.invoice.currency}',
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              context.tr('finance.products'),
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            _Box(
              children: invoice.lines.isEmpty
                  ? [Text(context.tr('finance.no_data'))]
                  : invoice.lines
                        .map<Widget>(
                          (line) => _Row(
                            '${line.name} × ${line.quantity.toStringAsFixed(0)}',
                            '${line.total.toStringAsFixed(2)} ${invoice.invoice.currency}',
                          ),
                        )
                        .toList(),
            ),
            SizedBox(height: 18.h),
            Text(
              context.tr('finance.tax_breakdown'),
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            _Box(
              children: invoice.taxRows.isEmpty
                  ? [Text(context.tr('finance.no_data'))]
                  : invoice.taxRows
                        .map<Widget>(
                          (tax) => _Row(
                            tax.label,
                            '${tax.value.toStringAsFixed(2)} ${invoice.invoice.currency}',
                          ),
                        )
                        .toList(),
            ),
          ],
        );
      },
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: const Color(0x12000000)),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const Divider(height: 24),
        ],
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: AppColors.onboardingPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    ],
  );
}
