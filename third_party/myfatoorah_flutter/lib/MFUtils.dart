// ignore_for_file: file_names

import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/MFModels.dart';

modelParser<T>(List<Object?>? replyList) {
  if (replyList == null) {
    throw PlatformException(
      code: 'channel-error',
      message: 'Unable to establish connection on channel.',
    );
  } else if (replyList.length > 1) {
    throw MFError(
        code: replyList[0] as String, message: replyList[1] as String);
    // throw PlatformException(
    //   code: replyList[0]! as String,
    //   message: replyList[1] as String?,
    //   details: replyList[2],
    // );
  } else if (replyList[0] == null) {
    throw PlatformException(
      code: 'null-error',
      message: 'Host platform returned null value for non-null return value.',
    );
  } else {
    return (replyList[0] as T?)!;
  }
}

int getColorHexFromStr(String colorStr) {
  colorStr = "FF$colorStr";
  colorStr = colorStr.replaceAll("#", "");
  int val = 0;
  int len = colorStr.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = colorStr.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw const FormatException("An error occurred when converting a color");
    }
  }
  return val;
}
