import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/insights/data/models/insights_model.dart';
import 'package:montajat_customer_app/features/insights/logic/insights_cubit.dart';
import 'package:montajat_customer_app/features/insights/logic/insights_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('insights-screen'),
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: const BackButton(),
      title: Text(
        context.tr('insights.title'),
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: BlocBuilder<InsightsCubit, InsightsState>(
      builder: (context, state) {
        if (state.status == InsightsLoadStatus.initial ||
            state.status == InsightsLoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.insights == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr(
                    state.errorMessageKey ?? 'auth_errors.request_failed',
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  onPressed: context.read<InsightsCubit>().load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          );
        }
        return _InsightsContent(insights: state.insights!);
      },
    ),
  );
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({required this.insights});

  final InsightsModel insights;

  @override
  Widget build(BuildContext context) {
    final summary = insights.summary;
    return RefreshIndicator(
      color: AppColors.onboardingPrimary,
      onRefresh: context.read<InsightsCubit>().load,
      child: ListView(
        key: const ValueKey('insights-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
        children: [
          _PeriodCard(
            from: insights.from,
            to: insights.to,
            onTap: () => _selectPeriod(context, insights),
          ),
          SizedBox(height: 14.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.48,
            children: [
              _MetricCard(
                label: context.tr('insights.total_spend'),
                value: _money(summary.totalSpend, summary.currency),
                icon: Icons.payments_outlined,
              ),
              _MetricCard(
                label: context.tr('insights.outstanding'),
                value: _money(summary.outstanding, summary.currency),
                icon: Icons.account_balance_wallet_outlined,
              ),
              _MetricCard(
                label: context.tr('insights.invoices'),
                value: '${summary.invoiceCount}',
                icon: Icons.receipt_long_outlined,
              ),
              _MetricCard(
                label: context.tr('insights.average_invoice'),
                value: _money(summary.averageInvoice, summary.currency),
                icon: Icons.analytics_outlined,
              ),
              _MetricCard(
                label: context.tr('insights.total_quantity'),
                value: _number(summary.totalQuantity),
                icon: Icons.inventory_2_outlined,
              ),
              _MetricCard(
                label: context.tr('insights.distinct_items'),
                value: '${summary.distinctItems}',
                icon: Icons.category_outlined,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          _SectionCard(
            title: context.tr('insights.monthly_sales'),
            child: _MonthlyChart(
              items: insights.monthly,
              currency: summary.currency,
            ),
          ),
          SizedBox(height: 14.h),
          _SectionCard(
            title: context.tr('insights.top_items'),
            child: Column(
              children: insights.topItems
                  .map(
                    (item) =>
                        _TopItemRow(item: item, currency: summary.currency),
                  )
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionCard(
                  title: context.tr('insights.top_brands'),
                  child: _Groups(items: insights.topBrands),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SectionCard(
                  title: context.tr('insights.top_categories'),
                  child: _Groups(items: insights.topCategories),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ReturnsCard(returns: insights.returns, currency: summary.currency),
        ],
      ),
    );
  }

  Future<void> _selectPeriod(
    BuildContext context,
    InsightsModel insights,
  ) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: insights.from.isAfter(now) ? now : insights.from,
        end: insights.to.isAfter(now) ? now : insights.to,
      ),
      helpText: context.tr('insights.select_period'),
      cancelText: context.tr('insights.cancel'),
      confirmText: context.tr('insights.apply'),
      saveText: context.tr('insights.apply'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.onboardingPrimary),
        ),
        child: child!,
      ),
    );
    if (range == null || !context.mounted) return;
    await context.read<InsightsCubit>().selectPeriod(range.start, range.end);
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.from,
    required this.to,
    required this.onTap,
  });
  final DateTime from;
  final DateTime to;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(14.r),
    clipBehavior: Clip.antiAlias,
    child: Ink(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F86C6), Color(0xFF376DAF)],
        ),
      ),
      child: InkWell(
        key: const ValueKey('insights-date-filter'),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('insights.filter_by_date'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${DateFormat('yyyy/MM/dd').format(from)} - '
                      '${DateFormat('yyyy/MM/dd').format(to)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFEAEAEA)),
    ),
    child: Row(
      children: [
        Container(
          width: 38.r,
          height: 38.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D8),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: const Color(0xFFF5A900), size: 21.sp),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: const Color(0xFFEAEAEA)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 14.h),
        child,
      ],
    ),
  );
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.items, required this.currency});
  final List<InsightGroup> items;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Text(context.tr('insights.no_data'));
    final maximum = items
        .map((item) => item.revenue)
        .fold<num>(0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 145.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items
            .map((item) {
              final ratio = maximum == 0 ? 0.0 : item.revenue / maximum;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _compact(item.revenue),
                        style: TextStyle(fontSize: 9.sp),
                      ),
                      SizedBox(height: 5.h),
                      Container(
                        height: (90.h * ratio).clamp(8.h, 90.h),
                        decoration: BoxDecoration(
                          color: AppColors.onboardingPrimary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(5.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        item.key.substring(5),
                        style: TextStyle(fontSize: 9.sp),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _TopItemRow extends StatelessWidget {
  const _TopItemRow({required this.item, required this.currency});
  final InsightTopItem item;
  final String currency;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 13.h),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: const Color(0xFFFFF4D8),
          child: Text(
            '${item.rank}',
            style: const TextStyle(
              color: Color(0xFFF5A900),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              Text(
                '${_number(item.quantity)} ${context.tr('insights.units')} • ${item.purchaseCount} ${context.tr('insights.purchases')}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          _money(item.revenue, currency),
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.onboardingPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _Groups extends StatelessWidget {
  const _Groups({required this.items});
  final List<InsightGroup> items;

  @override
  Widget build(BuildContext context) => Column(
    children: items.isEmpty
        ? [Text(context.tr('insights.no_data'))]
        : items
              .take(4)
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${_number(item.share)}%',
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      LinearProgressIndicator(
                        value: (item.share / 100).clamp(0, 1).toDouble(),
                        minHeight: 5.h,
                        borderRadius: BorderRadius.circular(5.r),
                        color: const Color(0xFFF5A900),
                        backgroundColor: const Color(0xFFF2F2F2),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
  );
}

class _ReturnsCard extends StatelessWidget {
  const _ReturnsCard({required this.returns, required this.currency});
  final InsightReturns returns;
  final String currency;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: context.tr('insights.returns'),
    child: Column(
      children: [
        _DataLine(
          label: context.tr('insights.returned_value'),
          value: _money(returns.returnedAmount, currency),
        ),
        _DataLine(
          label: context.tr('insights.return_rate'),
          value: '${_number(returns.ratio)}%',
        ),
        _DataLine(
          label: context.tr('insights.credit_notes'),
          value: '${returns.creditNoteCount}',
        ),
      ],
    ),
  );
}

class _DataLine extends StatelessWidget {
  const _DataLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

String _money(num value, String currency) => '${_number(value)} $currency';
String _number(num value) => NumberFormat('#,##0.##').format(value);
String _compact(num value) => NumberFormat.compact().format(value);
