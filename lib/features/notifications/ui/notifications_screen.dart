import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/notifications/data/models/app_notification_model.dart';
import 'package:montajat_customer_app/features/notifications/logic/notifications_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<NotificationsCubit, NotificationsState>(
    listener: (context, state) {
      if (state.error != null) {
        AppConstant.toast(context.tr(state.error!), false, context);
      }
    },
    builder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(context.tr('notifications.title')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) => context.read<NotificationsCubit>().readAll(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'read_all',
                enabled: state.unreadCount > 0,
                child: Text(context.tr('notifications.read_all')),
              ),
            ],
          ),
        ],
      ),
      body: state.loading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: context.read<NotificationsCubit>().load,
              child: state.items.isEmpty
                  ? _Empty(onRefresh: context.read<NotificationsCubit>().load)
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (_, index) {
                        final item = state.items[index];
                        return Dismissible(
                          key: ValueKey('notification-${item.id}'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) =>
                              context.read<NotificationsCubit>().delete(item),
                          background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: EdgeInsetsDirectional.only(end: 24.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5151),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          child: _NotificationCard(item: item),
                        );
                      },
                    ),
            ),
    ),
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final AppNotificationModel item;

  @override
  Widget build(BuildContext context) => Material(
    color: item.isRead ? Colors.white : const Color(0xFFF5F9FE),
    borderRadius: BorderRadius.circular(14.r),
    elevation: 1.5,
    shadowColor: const Color(0x18000000),
    child: InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () => context.read<NotificationsCubit>().markAsRead(item),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE9F8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: AppColors.onboardingPrimary,
                size: 22.sp,
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
                          item.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: AppColors.onboardingPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    _date(context, item.createdAt),
                    style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                  ),
                  if (item.body.isNotEmpty) ...[
                    SizedBox(height: 9.h),
                    Text(
                      item.body,
                      style: TextStyle(fontSize: 12.sp, height: 1.6),
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

  String _date(BuildContext context, DateTime? value) {
    if (value == null) return '';
    return DateFormat(
      'd MMMM yyyy - h:mm a',
      context.locale.languageCode,
    ).format(value.toLocal());
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onRefresh});
  final Future<void> Function() onRefresh;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: 190.h),
      Icon(
        Icons.notifications_none_rounded,
        size: 86.sp,
        color: const Color(0xFFC9D9EC),
      ),
      SizedBox(height: 16.h),
      Text(
        context.tr('notifications.empty'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
