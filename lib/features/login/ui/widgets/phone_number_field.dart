import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    required this.controller,
    required this.errorKey,
    required this.onChanged,
    required this.onCountryChanged,
    super.key,
  });

  final TextEditingController controller;
  final String? errorKey;
  final ValueChanged<String> onChanged;
  final ValueChanged<CountryCode> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: errorKey == null
                          ? AppColors.fieldBorder
                          : Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              PositionedDirectional(
                top: -10.h,
                end: 13.w,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    context.tr('login.phone_label'),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 4.w,
                top: 0,
                bottom: 0,
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: CountryCodePicker(
                    key: const ValueKey('login-country-code-picker'),
                    initialSelection: 'SA',
                    favorite: const ['SA', '+966'],
                    onChanged: onCountryChanged,
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    flagWidth: 29.w,
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    textStyle: TextStyle(
                      color: const Color(0xFF9A9A9A),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    dialogTextStyle: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 15.sp,
                    ),
                    searchDecoration: InputDecoration(
                      hintText: context.tr('login.country_search'),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 132.w,
                end: 14.w,
                top: 4.h,
                bottom: 2.h,
                child: TextField(
                  key: const ValueKey('login-phone-field'),
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  textDirection: ui.TextDirection.ltr,
                  textAlign: TextAlign.end,
                  maxLength: 12,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: context.tr('login.phone_hint'),
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorKey != null) ...[
          SizedBox(height: 6.h),
          Text(
            context.tr(errorKey!),
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
