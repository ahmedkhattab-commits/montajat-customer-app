import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorAlertDialog {
  const ErrorAlertDialog();

  static Future<void> getDialog(
    BuildContext context,
    String error, {
    bool isPop = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(""),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isPop) {
                  Navigator.pop(context);
                }
              },
              child: Text("ok".tr()),
            ),
          ],
        );
      },
    );
  }
}
