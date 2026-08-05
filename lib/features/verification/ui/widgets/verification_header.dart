import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationHeader extends StatelessWidget {
  const VerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            context.tr('verification.title'),
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          PositionedDirectional(
            start: 0,
            child: IconButton(
              key: const ValueKey('verification-back'),
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Directionality.of(context) == ui.TextDirection.rtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                textDirection: ui.TextDirection.ltr,
                size: 25.sp,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
