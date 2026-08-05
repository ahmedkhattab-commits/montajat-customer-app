import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:montajat_customer_app/my_app.dart';

///redesign this widget
class OfflineAlertDialog {
  const OfflineAlertDialog();

  static Future<void> getDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("noInternet".tr()),
          content: Text("noInternetText".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ok".tr()),
            ),
          ],
        );
      },
    );
  }
}
