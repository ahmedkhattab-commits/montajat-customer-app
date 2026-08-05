import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

ConnectivityResult? source = ConnectivityResult.none;
MyConnectivity connectivity = MyConnectivity.instance;

class MyConnectivity {
  MyConnectivity._internal();

  static final MyConnectivity _instance = MyConnectivity._internal();

  static MyConnectivity get instance => _instance;

  static Connectivity connectivity = Connectivity();
  static StreamController<Map<String, bool>> controller =
      StreamController.broadcast();

  static Stream<Map<String, bool>> get myStream => controller.stream;

  static Future<void> initialise() async {
    final List<ConnectivityResult> result = await (connectivity
        .checkConnectivity());
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) async {
      debugPrint("onConnectivity Changed changed");
      debugPrint(result[0].toString());
      source = result[0];
      _checkStatus(result);
    });
  }

  static void _checkStatus(List<ConnectivityResult> result) async {
    bool isOnline = false;
    if (!result.contains(ConnectivityResult.none)) {
      isOnline = true;
    } else {
      isOnline = false;
    }
    debugPrint(isOnline.toString());
    controller.sink.add({"result": isOnline});
  }

  void disposeStream() => controller.close();

  static bool isOnline() => source != ConnectivityResult.none;
}
