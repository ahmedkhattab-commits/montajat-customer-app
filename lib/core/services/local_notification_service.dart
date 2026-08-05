// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
//
// class LocalNotificationService {
//   static final awesomeNotifications = AwesomeNotifications();
//
//   static Future<void> initializedNotification() async {
//     await awesomeNotifications.initialize(
//         null,
//         [
//           NotificationChannel(
//             channelGroupKey: 'basic_channel_group',
//             channelKey: 'basic_channel',
//             channelName: 'Basic notifications',
//             channelDescription: 'Notification channel for basic tests',
//             defaultColor: Color(0xFF9D50DD),
//             ledColor: Colors.white,
//             importance: NotificationImportance.Max,
//             channelShowBadge: true,
//             onlyAlertOnce: true,
//             playSound: true,
//             criticalAlerts: true,
//           ),
//         ],
//         channelGroups: [
//           NotificationChannelGroup(
//               channelGroupKey: 'basic_channel_group',
//               channelGroupName: 'Basic group')
//         ],
//         debug: true);
//
//     await awesomeNotifications.isNotificationAllowed().then((isAllowed) async {
//       if (!isAllowed) {
//         await awesomeNotifications.requestPermissionToSendNotifications();
//       }
//     });
//
//     await awesomeNotifications.setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//       onNotificationCreatedMethod: onNotificationCreatedMethod,
//       onNotificationDisplayedMethod: onNotificationDisplayedMethod,
//       onDismissActionReceivedMethod: onDismissActionReceivedMethod,
//     );
//   }
//
//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     print("onActionReceivedMethod");
//     final payLoad = receivedAction.payload ?? {};
//     // if (payLoad['navigate'] == "true") {
//     //   if (payLoad['click_action'] == "send_chat") {
//     //
//     //     PusherService(NinjaApp.navigatorKey.currentContext!).initPusher();
//     //
//     //     ChatCubit.get(NinjaApp.navigatorKey.currentContext!).clearChatData();
//     //     ChatCubit.get(NinjaApp.navigatorKey.currentContext!).getAllMessages(
//     //         int.tryParse(payLoad['orderId'].toString()) ?? 0,
//     //         int.tryParse(payLoad['receiveId'].toString()) ?? 0);
//     //
//     //     NinjaApp.navigatorKey.currentContext!
//     //         .pushNamed(Routes.chatDetailsScreen, arguments: {
//     //       'myId': AuthenticationCubit.get(NinjaApp.navigatorKey.currentContext!)
//     //           .userInfo!
//     //           .data
//     //           .id,
//     //       'receiveId': payLoad['receiveId'],
//     //       'orderId': payLoad['orderId'],
//     //       'name': payLoad['name'].toString(),
//     //       'phone': payLoad['phone'].toString(),
//     //       'image': EndPoints.getImageFromApi(payLoad['image'].toString()),
//     //     });
//     //   }
//     //   else if (payLoad['click_action'] == "USER_CONFIRMED") {
//     //     ButtonBarHomeCubit.get(NinjaApp.navigatorKey.currentContext)
//     //         .changeIndex(0);
//     //     NinjaApp.navigatorKey.currentContext!
//     //         .pushNamed(Routes.buttonBarHomeScreen);
//     //   }
//     //   else if (payLoad['click_action'] == "NINJA_APPROVED") {
//     //     ButtonBarHomeCubit.get(NinjaApp.navigatorKey.currentContext)
//     //         .changeIndex(2);
//     //     NinjaApp.navigatorKey.currentContext!
//     //         .pushNamed(Routes.buttonBarHomeScreen);
//     //   }
//     //   else if (payLoad['click_action'] == "NINJA_ACCOUNT_APPROVED" ||
//     //       payLoad['click_action'] == "NINJA_ACCOUNT_REJECTED" ||
//     //       payLoad['click_action'] == "DATA_ERROR" ||
//     //       payLoad['click_action'] == "NEW_ORDER_FOR_NINJA" ||
//     //       payLoad['click_action'] == "user-canceled-order") {
//     //     ButtonBarProviderCubit.get(NinjaApp.navigatorKey.currentContext)
//     //         .changeIndex(0);
//     //     NinjaApp.navigatorKey.currentContext!
//     //         .pushNamed(Routes.buttonBarProviderScreen);
//     //   }
//     //   else if (payLoad['click_action'] == "NINJA_CONFIRMED" ||
//     //       payLoad['click_action'] == "sendOrderHour") {
//     //     ButtonBarProviderCubit.get(NinjaApp.navigatorKey.currentContext)
//     //         .changeIndex(2);
//     //     NinjaApp.navigatorKey.currentContext!
//     //         .pushNamed(Routes.buttonBarProviderScreen);
//     //   }
//     // }
//   }
//
//   static Future<void> onNotificationCreatedMethod(
//       ReceivedNotification receivedAction) async {
//     print("onNotificationCreatedMethod");
//   }
//
//   static Future<void> onNotificationDisplayedMethod(
//       ReceivedNotification receivedAction) async {
//     print("onNotificationDisplayedMethod");
//   }
//
//   static Future<void> onDismissActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     print("onDismissActionReceivedMethod");
//   }
//
//   static Future<void> showNotification({
//     required final String title,
//     required final String body,
//     final String? summary,
//     final Map<String, String>? payload,
//     final ActionType actionType = ActionType.Default,
//     final NotificationLayout notificationLayout = NotificationLayout.Default,
//     final NotificationCategory? category,
//     final String? bigPicture,
//     final List<NotificationActionButton>? actionButtons,
//     final bool schedule = false,
//     final int? interval,
//   }) async {
//     await awesomeNotifications.createNotification(
//       content: NotificationContent(
//         id: -1,
//         channelKey: 'basic_channel',
//         title: title,
//         body: body,
//         actionType: actionType,
//         notificationLayout: notificationLayout,
//         summary: summary,
//         category: category,
//         payload: payload,
//         bigPicture: bigPicture,
//       ),
//       actionButtons: actionButtons,
//       schedule: schedule
//           ? NotificationInterval(
//           interval: interval,
//           timeZone: await awesomeNotifications.getLocalTimeZoneIdentifier(),
//           preciseAlarm: true)
//           : null,
//     );
//   }
// }
