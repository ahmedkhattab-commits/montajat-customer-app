import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/finance/data/models/finance_models.dart';
import 'package:montajat_customer_app/features/finance/logic/finance_cubit.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 5,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 72.h,
        title: Text(
          context.tr('finance.title'),
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.onboardingPrimary,
          unselectedLabelColor: const Color(0xFF8E8E8E),
          indicatorColor: AppColors.onboardingPrimary,
          dividerColor: const Color(0xFFEDEDED),
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: context.tr('finance.dashboard')),
            Tab(text: context.tr('finance.invoices')),
            Tab(text: context.tr('finance.payments')),
            Tab(text: context.tr('finance.credit_notes')),
            Tab(text: context.tr('finance.statement')),
          ],
        ),
      ),
      body: BlocBuilder<FinanceCubit, FinanceState>(
        builder: (context, state) {
          if (state.status == FinanceStatus.loading ||
              state.status == FinanceStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FinanceStatus.failure) {
            return _ErrorView(errorKey: state.errorKey);
          }
          return TabBarView(
            children: [
              _Dashboard(state: state),
              _Documents(items: state.invoices, type: _DocumentType.invoice),
              _Documents(items: state.payments, type: _DocumentType.payment),
              _Documents(
                items: state.creditNotes,
                type: _DocumentType.creditNote,
              ),
              _Documents(items: state.statement, type: _DocumentType.statement),
            ],
          );
        },
      ),
    ),
  );
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.state});
  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;
    return RefreshIndicator(
      onRefresh: context.read<FinanceCubit>().load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(18.w),
        children: [
          if (state.status == FinanceStatus.partial) ...[
            _Notice(message: context.tr('finance.partial_data')),
            SizedBox(height: 12.h),
          ],
          _BalanceHeader(summary: summary),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  labelKey: 'finance.available_credit',
                  value: _money(
                    summary.creditAvailable,
                    summary.currency,
                    context,
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricCard(
                  labelKey: 'finance.used_credit',
                  value: _money(summary.creditUsed, summary.currency, context),
                  icon: Icons.pie_chart_outline_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _MetricCard(
            labelKey: 'finance.overdue_amount',
            value: _money(summary.overdue, summary.currency, context),
            icon: Icons.warning_amber_rounded,
            warning: summary.overdue > 0,
          ),
          SizedBox(height: 20.h),
          _SectionTitle(context.tr('finance.aging')),
          _Panel(
            children: state.aging.isEmpty
                ? [Text(context.tr('finance.no_data'))]
                : state.aging
                      .map(
                        (item) => _ValueRow(
                          _agingLabel(context, item.label),
                          _money(item.amount, summary.currency, context),
                        ),
                      )
                      .toList(),
          ),
        ],
      ),
    );
  }
}

class _Documents extends StatelessWidget {
  const _Documents({required this.items, required this.type});
  final List<FinanceDocumentModel> items;
  final _DocumentType type;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: context.read<FinanceCubit>().load,
    child: items.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 220.h),
              Icon(
                Icons.receipt_long_outlined,
                size: 74.sp,
                color: const Color(0xFFD0D0D0),
              ),
              SizedBox(height: 12.h),
              Text(context.tr('finance.no_data'), textAlign: TextAlign.center),
            ],
          )
        : ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(18.w),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, index) =>
                _DocumentCard(item: items[index], type: type),
          ),
  );
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.item, required this.type});
  final FinanceDocumentModel item;
  final _DocumentType type;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.r),
    child: InkWell(
      onTap: type == _DocumentType.invoice && item.number != '-'
          ? () => Navigator.pushNamed(
              context,
              Routes.financeInvoiceDetails,
              arguments: item.number,
            )
          : null,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_icon(type), color: const Color(0xFFF5B335)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item.number,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Text(
                  _money(item.amount, item.currency, context),
                  style: TextStyle(
                    color: AppColors.onboardingPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _CardMeta(
                    labelKey: 'finance.document_date',
                    value: _date(item.date),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30.h,
                  color: const Color(0xFFEAEAEA),
                ),
                Expanded(
                  child: _CardMeta(
                    labelKey: 'finance.status',
                    value: item.status,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.labelKey,
    required this.value,
    required this.icon,
    this.warning = false,
  });
  final String labelKey;
  final String value;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(
        color: warning ? const Color(0x44E95353) : const Color(0x12000000),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: warning ? const Color(0xFFE95353) : const Color(0xFFF5B335),
        ),
        SizedBox(height: 14.h),
        Text(
          value,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4.h),
        Text(
          context.tr(labelKey),
          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
        ),
      ],
    ),
  );
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.summary});
  final FinanceSummaryModel summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: AppColors.onboardingPrimary,
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: Color(0x26FFFFFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: 26.sp,
          ),
        ),
        SizedBox(width: 13.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('finance.outstanding_balance'),
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
              SizedBox(height: 5.h),
              Text(
                _money(summary.currentBalance, summary.currency, context),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF6E0),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Color(0xFFF3B443)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(message, style: TextStyle(fontSize: 12.sp)),
        ),
      ],
    ),
  );
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({required this.labelKey, required this.value});
  final String labelKey;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        context.tr(labelKey),
        style: TextStyle(color: const Color(0xFFAAAAAA), fontSize: 10.sp),
      ),
      SizedBox(height: 4.h),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(top: 9.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const Divider(height: 22),
        ],
      ],
    ),
  );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value);
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
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.errorKey});
  final String? errorKey;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(errorKey ?? 'auth_errors.request_failed')),
        IconButton(
          onPressed: context.read<FinanceCubit>().load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );
}

enum _DocumentType { invoice, payment, creditNote, statement }

IconData _icon(_DocumentType type) => switch (type) {
  _DocumentType.invoice => Icons.receipt_long_outlined,
  _DocumentType.payment => Icons.payments_outlined,
  _DocumentType.creditNote => Icons.assignment_return_outlined,
  _DocumentType.statement => Icons.list_alt_rounded,
};
String _money(num value, String currency, BuildContext context) =>
    '${value.toStringAsFixed(2)} ${currency.toUpperCase() == 'SAR' ? context.tr('finance.sar') : currency}';
String _date(DateTime? date) =>
    date == null ? '-' : DateFormat('yyyy/MM/dd').format(date.toLocal());

String _agingLabel(BuildContext context, String value) {
  final key = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  const supported = {
    'current',
    'not_due',
    '0_30',
    '31_60',
    '61_90',
    'over_90',
    '90_plus',
  };
  return supported.contains(key) ? context.tr('finance.aging_$key') : value;
}
