import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/reports/data/models/report_models.dart';
import 'package:montajat_customer_app/features/reports/logic/reports_cubit.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _types = [
    _ReportType(
      'purchases_by_period',
      'reports.purchases',
      Icons.shopping_bag_outlined,
    ),
    _ReportType('top_items', 'reports.top_items', Icons.trending_up_rounded),
    _ReportType(
      'stopped_items',
      'reports.stopped_items',
      Icons.remove_shopping_cart_outlined,
    ),
    _ReportType('annual_savings', 'reports.savings', Icons.savings_outlined),
    _ReportType(
      'returns_ratio',
      'reports.returns',
      Icons.assignment_return_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 72.h,
        title: Text(
          context.tr('reports.title'),
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          labelColor: AppColors.onboardingPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.onboardingPrimary,
          tabs: [
            Tab(text: context.tr('reports.available')),
            Tab(text: context.tr('reports.saved')),
            Tab(text: context.tr('reports.files')),
          ],
        ),
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.initial ||
              state.status == ReportsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ReportsStatus.failure) {
            return _ErrorView(errorKey: state.errorKey);
          }
          return TabBarView(
            children: [
              _AvailableReports(state: state),
              _SavedReports(items: state.saved),
              _ReportFiles(items: state.runs),
            ],
          );
        },
      ),
    ),
  );
}

class _AvailableReports extends StatefulWidget {
  const _AvailableReports({required this.state});
  final ReportsState state;

  @override
  State<_AvailableReports> createState() => _AvailableReportsState();
}

class _AvailableReportsState extends State<_AvailableReports> {
  late DateTimeRange _range;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
  }

  Map<String, String> get _filters => {
    'from': DateFormat('yyyy-MM-dd').format(_range.start),
    'to': DateFormat('yyyy-MM-dd').format(_range.end),
  };

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: context.read<ReportsCubit>().load,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(18.w),
      children: [
        _DateFilter(range: _range, onTap: _selectRange),
        SizedBox(height: 12.h),
        for (var index = 0; index < ReportsScreen._types.length; index++) ...[
          _ReportCard(
            type: ReportsScreen._types[index],
            filters: _filters,
            loadingAction:
                widget.state.activeType == ReportsScreen._types[index].type
                ? widget.state.activeAction
                : null,
          ),
          if (index < ReportsScreen._types.length - 1) SizedBox(height: 10.h),
        ],
      ],
    ),
  );

  Future<void> _selectRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (selected != null && mounted) setState(() => _range = selected);
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.type,
    required this.loadingAction,
    required this.filters,
  });
  final _ReportType type;
  final String? loadingAction;
  final Map<String, String> filters;

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
        Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(type.icon, color: const Color(0xFFF5B335)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                context.tr(type.labelKey),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: loadingAction != null
                    ? null
                    : () async {
                        final ok = await context.read<ReportsCubit>().run(
                          type.type,
                          filters: filters,
                        );
                        if (!context.mounted) return;
                        if (ok) {
                          _showResult(context);
                        } else {
                          _showError(context);
                        }
                      },
                child: loadingAction == 'view'
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onboardingPrimary,
                        ),
                      )
                    : Text(context.tr('reports.view')),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.onboardingPrimary,
                ),
                onPressed: loadingAction != null
                    ? null
                    : () => _export(context, 'pdf'),
                child: loadingAction == 'pdf'
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.tr('reports.export_pdf')),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: loadingAction != null
                    ? null
                    : () => _export(context, 'xlsx'),
                icon: loadingAction == 'xlsx'
                    ? SizedBox(
                        width: 17.w,
                        height: 17.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onboardingPrimary,
                        ),
                      )
                    : const Icon(Icons.table_view_outlined, size: 17),
                label: const Text('Excel'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _export(BuildContext context, String format) async {
    final ok = await context.read<ReportsCubit>().export(
      type.type,
      format,
      filters: filters,
    );
    if (!context.mounted) return;
    AppConstant.toast(
      context.tr(
        ok
            ? 'reports.export_started'
            : context.read<ReportsCubit>().state.errorKey ??
                  'reports.action_failed',
      ),
      ok,
      context,
    );
  }

  void _showError(BuildContext context) {
    AppConstant.toast(
      context.tr(
        context.read<ReportsCubit>().state.errorKey ?? 'reports.action_failed',
      ),
      false,
      context,
    );
  }

  void _showResult(BuildContext context) {
    final result = context.read<ReportsCubit>().state.result;
    if (result == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ReportResultScreen(
          title: context.tr(type.labelKey),
          result: result,
        ),
      ),
    );
  }
}

class _DateFilter extends StatelessWidget {
  const _DateFilter({required this.range, required this.onTap});
  final DateTimeRange range;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        child: Row(
          children: [
            Icon(Icons.date_range_outlined, color: AppColors.onboardingPrimary),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '${DateFormat('yyyy/MM/dd').format(range.start)} - ${DateFormat('yyyy/MM/dd').format(range.end)}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              context.tr('reports.change_period'),
              style: TextStyle(
                color: AppColors.onboardingPrimary,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SavedReports extends StatelessWidget {
  const _SavedReports({required this.items});
  final List<SavedReportModel> items;
  @override
  Widget build(BuildContext context) => _ListOrEmpty(
    emptyKey: 'reports.no_saved',
    count: items.length,
    itemBuilder: (index) => _SimpleCard(
      icon: Icons.bookmark_outline,
      title: items[index].name,
      subtitle: _typeLabel(context, items[index].type),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Color(0xFFE95353)),
        onPressed: () async {
          await context.read<ReportsCubit>().deleteSaved(items[index].id);
          if (!context.mounted) return;
          final error = context.read<ReportsCubit>().state.errorKey;
          AppConstant.toast(
            context.tr(error ?? 'reports.deleted'),
            error == null,
            context,
          );
        },
      ),
    ),
  );
}

class _ReportFiles extends StatelessWidget {
  const _ReportFiles({required this.items});
  final List<ReportRunModel> items;
  @override
  Widget build(BuildContext context) => _ListOrEmpty(
    emptyKey: 'reports.no_files',
    count: items.length,
    itemBuilder: (index) {
      final item = items[index];
      return _SimpleCard(
        icon: item.format?.toLowerCase() == 'pdf'
            ? Icons.picture_as_pdf_outlined
            : Icons.table_view_outlined,
        title: item.fileName ?? _typeLabel(context, item.type),
        subtitle: '${item.status}  •  ${_date(item.createdAt)}',
        trailing: IconButton(
          icon: Icon(
            Icons.download_rounded,
            color: item.canDownload ? AppColors.onboardingPrimary : Colors.grey,
          ),
          onPressed: !item.canDownload
              ? null
              : () async {
                  try {
                    final uri = await context.read<ReportsCubit>().download(
                      item.id,
                    );
                    final opened = uri.isScheme('file')
                        ? (await OpenFilex.open(uri.toFilePath())).type ==
                              ResultType.done
                        : await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                    if (!opened && context.mounted) {
                      AppConstant.toast(
                        context.tr('reports.download_failed'),
                        false,
                        context,
                      );
                    }
                  } on Object {
                    if (context.mounted) {
                      AppConstant.toast(
                        context.tr('reports.download_failed'),
                        false,
                        context,
                      );
                    }
                  }
                },
        ),
      );
    },
  );
}

class _ListOrEmpty extends StatelessWidget {
  const _ListOrEmpty({
    required this.emptyKey,
    required this.count,
    required this.itemBuilder,
  });
  final String emptyKey;
  final int count;
  final Widget Function(int) itemBuilder;
  @override
  Widget build(BuildContext context) => count == 0
      ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 220.h),
            Icon(
              Icons.insert_chart_outlined_rounded,
              size: 76.sp,
              color: const Color(0xFFD0D0D0),
            ),
            SizedBox(height: 12.h),
            Text(context.tr(emptyKey), textAlign: TextAlign.center),
          ],
        )
      : ListView.separated(
          padding: EdgeInsets.all(18.w),
          itemCount: count,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (_, index) => itemBuilder(index),
        );
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFF5B335)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey, fontSize: 11.sp),
              ),
            ],
          ),
        ),
        trailing,
      ],
    ),
  );
}

class ReportResultScreen extends StatelessWidget {
  const ReportResultScreen({
    required this.title,
    required this.result,
    super.key,
  });
  final String title;
  final ReportResultModel result;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(title),
    ),
    body: result.rows.isEmpty
        ? Center(child: Text(context.tr('reports.no_data')))
        : ListView.separated(
            padding: EdgeInsets.all(18.w),
            itemCount: result.rows.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, index) => Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: result.columns
                    .map(
                      (column) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                column,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${result.rows[index][column] ?? '-'}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
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
          onPressed: context.read<ReportsCubit>().load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );
}

class _ReportType {
  const _ReportType(this.type, this.labelKey, this.icon);
  final String type;
  final String labelKey;
  final IconData icon;
}

String _typeLabel(BuildContext context, String type) {
  for (final item in ReportsScreen._types) {
    if (item.type == type) return context.tr(item.labelKey);
  }
  return type;
}

String _date(DateTime? date) =>
    date == null ? '-' : DateFormat('yyyy/MM/dd').format(date.toLocal());
