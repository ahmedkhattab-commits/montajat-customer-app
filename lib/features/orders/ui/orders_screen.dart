import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';
import 'package:montajat_customer_app/features/orders/data/models/order_model.dart';
import 'package:montajat_customer_app/features/orders/logic/orders_cubit.dart';
import 'package:montajat_customer_app/features/orders/logic/orders_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _showPaid = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('orders-screen'),
    backgroundColor: Colors.white,
    bottomNavigationBar: const HomeBottomNavigation(currentIndex: 3),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80.h,
      title: Text(
        context.tr('orders.title'),
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: _OrdersTabs(
            showPaid: _showPaid,
            onChanged: (value) => setState(() => _showPaid = value),
          ),
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              if (state.status == OrdersLoadStatus.initial ||
                  state.status == OrdersLoadStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == OrdersLoadStatus.failure) {
                return _OrdersError(messageKey: state.errorMessageKey);
              }
              final orders = state.orders
                  .where((order) => order.isPaid == _showPaid)
                  .toList(growable: false);
              return RefreshIndicator(
                color: AppColors.onboardingPrimary,
                onRefresh: context.read<OrdersCubit>().loadOrders,
                child: orders.isEmpty
                    ? _EmptyOrders(isPaid: _showPaid)
                    : ListView.separated(
                        key: ValueKey('orders-list-$_showPaid'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(22.w, 4.h, 22.w, 26.h),
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (_, index) =>
                            _OrderCard(order: orders[index]),
                      ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _OrdersTabs extends StatelessWidget {
  const _OrdersTabs({required this.showPaid, required this.onChanged});
  final bool showPaid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 56.h,
    padding: EdgeInsets.all(4.w),
    decoration: BoxDecoration(
      color: AppColors.onboardingPrimary,
      borderRadius: BorderRadius.circular(30.r),
    ),
    child: Row(
      children: [
        _TabButton(
          label: context.tr('orders.unpaid'),
          selected: !showPaid,
          onTap: () => onChanged(false),
        ),
        _TabButton(
          label: context.tr('orders.paid'),
          selected: showPaid,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(26.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26.r),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.onboardingPrimary : Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        key: ValueKey('order-${order.orderNumber}'),
        onTap: () =>
            Navigator.pushNamed(
              context,
              Routes.orderDetails,
              arguments: order.orderNumber,
            ).then((_) {
              if (context.mounted) context.read<OrdersCubit>().loadOrders();
            }),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE3E3E3)),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.onboardingPrimary,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('orders.amount_due')}: ${_money(order.grandTotal, order.currency)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${context.tr('orders.order_number')}: ${order.orderNumber}',
                          style: TextStyle(
                            color: const Color(0xFFAAAAAA),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                child: const Divider(height: 1, color: Color(0xFFECECEC)),
              ),
              Row(
                children: [
                  Expanded(
                    child: _CardDetail(
                      label: context.tr('orders.order_date'),
                      value: _date(order.createdAt),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 37.h,
                    color: const Color(0xFFECECEC),
                  ),
                  Expanded(
                    child: _CardDetail(
                      label: context.tr('orders.delivery_date'),
                      value: _date(order.requestedDeliveryDate),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                child: const Divider(height: 1, color: Color(0xFFECECEC)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${context.tr('orders.status')}: ${order.localizedStatus(locale)}',
                      style: TextStyle(
                        color: order.isPaid
                            ? const Color(0xFF3B9A65)
                            : const Color(0xFFE95353),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Text(
                    context.tr('orders.view_details'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
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
}

class _CardDetail extends StatelessWidget {
  const _CardDetail({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: TextStyle(color: const Color(0xFFAAAAAA), fontSize: 10.sp),
      ),
      SizedBox(height: 4.h),
      Text(
        value,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.isPaid});
  final bool isPaid;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: 145.h),
      Icon(
        Icons.receipt_long_outlined,
        size: 105.sp,
        color: const Color(0xFFF3B933),
      ),
      SizedBox(height: 24.h),
      Text(
        context.tr(isPaid ? 'orders.empty_paid' : 'orders.empty_unpaid'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 10.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 45.w),
        child: Text(
          context.tr('orders.empty_hint'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF888888),
            fontSize: 13.sp,
            height: 1.6,
          ),
        ),
      ),
    ],
  );
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({this.messageKey});
  final String? messageKey;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(messageKey ?? 'auth_errors.request_failed')),
        IconButton(
          onPressed: context.read<OrdersCubit>().loadOrders,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );
}

String _date(DateTime? date) =>
    date == null ? '-' : DateFormat('yyyy/MM/dd').format(date.toLocal());
String _money(num value, String currency) =>
    '${value.toStringAsFixed(2)} $currency';
