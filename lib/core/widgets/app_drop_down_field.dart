import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors_white_theme.dart';
import '../utils/styles.dart';

class AppDropDownField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  final String hintText;
  final List<dynamic> items;

  final Widget? suffixIcon;
  final Color? backgroundColor;
  final bool? autofocus;
  final Widget? prefixIcon;
  final Function(dynamic) onChanged;

  const AppDropDownField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.inputTextStyle,
    this.hintStyle,
    this.textStyle,
    this.textAlign,
    required this.hintText,
    required this.items,
    this.suffixIcon,
    this.backgroundColor,
    this.prefixIcon,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      autofocus: autofocus!,
      dropdownColor: backgroundColor ?? AppColors.whiteColor,
      items: items.map((dynamic element) {
        return DropdownMenuItem<dynamic>(
          value: element,
          child: Text(
            element.name,
            style: textStyle ?? TextStyles.font16BlackColorWeight400,
          ),
        );
      }).toList(),
      menuMaxHeight: 300.h,
      onChanged: (dynamic item) {
        onChanged(item!);
      },
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,

        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyColor200, width: 1.3),
              borderRadius: BorderRadius.circular(20.r),
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyColor200, width: 1.3),
              borderRadius: BorderRadius.circular(20.r),
            ),
        errorBorder:
            errorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.errorColor100,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
        focusedErrorBorder:
            focusedErrorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.errorColor100,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
        hintStyle: hintStyle ?? TextStyles.font16BlackColorWeight400,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        fillColor: backgroundColor ?? AppColors.whiteColor,
        filled: true,
      ),
      style: textStyle ?? TextStyles.font16BlackColorWeight400,
    );
  }
}
