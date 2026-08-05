import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors_white_theme.dart';
import '../utils/styles.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int maxLines;
  final String hintText;
  final bool? isObscureText;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final bool isPhoneNumber;
  final bool? isRegister;
  final bool? isLogin;
  final bool? autofocus;
  final Widget? prefixIcon;
  final bool? isEnable;
  final TextEditingController? controller;
  final Function(String?) validator;
  final Function(String)? onchange;
  final Function()? onTapOutside;
  final Function()? onTap;
  final TextInputType keyboardType;

  const AppTextFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.inputTextStyle,
    this.hintStyle,
    this.textStyle,
    this.isEnable,
    this.textAlign,
    required this.hintText,
    this.maxLines = 1,
    this.isObscureText,
    this.suffixIcon,
    this.backgroundColor,
    this.controller,
    this.prefixIcon,
    required this.validator,
    this.onchange,
    this.onTapOutside,
    this.onTap,
    required this.keyboardType,
    this.isPhoneNumber = false,
    this.isRegister = false,
    this.isLogin = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus!,
      controller: controller,
      maxLines: maxLines,
      enabled: isEnable ?? true,
      textAlign: textAlign ?? TextAlign.start,
      onTapOutside: (PointerDownEvent value) {
        FocusScope.of(context).unfocus();
        if (onTapOutside != null) {
          onTapOutside!();
        }
      },
      cursorColor: AppColors.blackColor.withValues(alpha: .8),
      enableSuggestions: true,
      autocorrect: true,
      autofillHints: const [AutofillHints.email],
      keyboardType: keyboardType,
      onChanged: (String value) {
        if (onchange != null) {
          onchange!(value);
        }
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        disabledBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyColor200, width: 1.3),
              borderRadius: BorderRadius.circular(20.r),
            ),
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
      obscureText: isObscureText ?? false,
      onTap: onTap,
      style: textStyle ?? TextStyles.font16BlackColorWeight400,
      validator: (value) {
        return validator(value);
      },
    );
  }
}
