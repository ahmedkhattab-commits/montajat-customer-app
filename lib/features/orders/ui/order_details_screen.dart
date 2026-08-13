import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';
import 'package:montajat_customer_app/features/orders/logic/order_details_cubit.dart';
import 'package:montajat_customer_app/features/orders/logic/order_details_state.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({required this.orderNumber, super.key});
  final String orderNumber;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('order-details-screen'),
    backgroundColor: Colors.white,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        key: const ValueKey('order-details-home'),
        onPressed: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.home, (_) => false),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 76.h,
      title: Text(
        context.tr('orders.details_title'),
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      ),
    ),
    body: BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
      listenWhen: (previous, current) =>
          previous.errorMessageKey != current.errorMessageKey &&
          current.errorMessageKey != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(state.errorMessageKey!))),
      ),
      builder: (context, state) {
        if (state.status == OrderDetailsStatus.initial ||
            state.status == OrderDetailsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == OrderDetailsStatus.failure || state.order == null) {
          return Center(
            child: IconButton(
              onPressed: context.read<OrderDetailsCubit>().loadOrder,
              icon: const Icon(Icons.refresh),
            ),
          );
        }
        return _OrderDetails(order: state.order!);
      },
    ),
  );
}

class _OrderDetails extends StatelessWidget {
  const _OrderDetails({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: AppColors.onboardingPrimary,
    onRefresh: context.read<OrderDetailsCubit>().loadOrder,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 30.h),
      children: [
        _InformationCard(order: order),
        SizedBox(height: 20.h),
        Text(
          context.tr('orders.products'),
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),
        ...order.lines.map(
          (line) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _OrderLineCard(line: line, currency: order.currency),
          ),
        ),
        _OrderSummary(order: order),
        if (order.isCancellable) ...[
          SizedBox(height: 22.h),
          BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
            builder: (context, state) => OutlinedButton(
              key: const ValueKey('cancel-order'),
              onPressed: state.cancelling
                  ? null
                  : () => _confirmCancel(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE95353),
                side: const BorderSide(color: Color(0x55E95353)),
                minimumSize: Size.fromHeight(54.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: state.cancelling
                  ? const CircularProgressIndicator()
                  : Text(
                      context.tr('orders.cancel_order'),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ],
    ),
  );

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('orders.cancel_order')),
        content: Text(context.tr('orders.cancel_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('profile.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE95353),
            ),
            child: Text(context.tr('orders.cancel_order')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final cancelled = await context.read<OrderDetailsCubit>().cancelOrder();
      if (cancelled && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('orders.cancelled_successfully'))),
        );
      }
    }
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return _BorderCard(
      child: Column(
        children: [
          _InfoRow(
            label: context.tr('orders.order_number'),
            value: order.orderNumber,
          ),
          _InfoRow(
            label: context.tr('orders.order_date'),
            value: _date(order.createdAt),
          ),
          _InfoRow(
            label: context.tr('orders.delivery_date'),
            value: _date(order.requestedDeliveryDate),
          ),
          _InfoRow(
            label: context.tr('orders.amount_due'),
            value: _money(order.grandTotal, order.currency),
          ),
          _InfoRow(
            label: context.tr('orders.status'),
            value: order.localizedStatus(languageCode),
            valueColor: order.isPaid
                ? const Color(0xFF3B9A65)
                : const Color(0xFFE95353),
            last: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.last = false,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: const Color(0xFF999999), fontSize: 12.sp),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _OrderLineCard extends StatelessWidget {
  const _OrderLineCard({required this.line, required this.currency});
  final OrderLineModel line;
  final String currency;

  @override
  Widget build(BuildContext context) => _BorderCard(
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 74.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFD3D3D3),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  '${context.tr('orders.quantity')}: ${line.quantity}',
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  '${context.tr('orders.total')}: ${_money(line.lineTotal, currency)}',
                  style: TextStyle(
                    color: const Color(0xFFE95353),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});
  final OrderModel order;
  @override
  Widget build(BuildContext context) => _BorderCard(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.onboardingPrimary,
              ),
              SizedBox(width: 7.w),
              Text(
                context.tr('orders.summary'),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(color: Color(0xFFEFEFEF)),
          _SummaryRow(
            label: context.tr('orders.items_count'),
            value: '${order.lines.length}',
          ),
          _SummaryRow(
            label: context.tr('orders.subtotal'),
            value: _money(order.subtotal, order.currency),
          ),
          _SummaryRow(
            label: context.tr('orders.vat'),
            value: _money(order.vat, order.currency),
          ),
          const Divider(color: Color(0xFFEFEFEF)),
          _SummaryRow(
            label: context.tr('orders.grand_total'),
            value: _money(order.grandTotal, order.currency),
            bold: true,
          ),
        ],
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 7.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? Colors.black : const Color(0xFF888888),
              fontSize: bold ? 15.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15.sp : 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _BorderCard extends StatelessWidget {
  const _BorderCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8E8E8)),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: child,
  );
}

String _date(DateTime? date) =>
    date == null ? '-' : DateFormat('yyyy/MM/dd').format(date.toLocal());
String _money(num value, String currency) =>
    '${value.toStringAsFixed(2)} $currency';
