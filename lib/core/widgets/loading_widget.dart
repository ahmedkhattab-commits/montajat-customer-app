import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;

  const LoadingWidget({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? Center(child: CircularProgressIndicator(color: color))
        : Center(child: CupertinoActivityIndicator(color: color));
  }
}
