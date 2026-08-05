import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/spacing.dart';
import 'package:montajat_customer_app/core/widgets/loading_widget.dart';

import '../utils/app_colors_white_theme.dart';

class ButtonWidget extends StatelessWidget {
  final bool isLoading;
  final double? borderRadius;
  final Color? borderColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? borderWidth;
  final Color? backGroundColor;
  final Color? fourGroundColor;
  final Color? iconColor;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final IconData? icon;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const ButtonWidget({
    super.key,
    required this.isLoading,
    this.borderRadius,
    this.borderColor,
    this.iconColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderWidth,
    this.backGroundColor,
    this.fourGroundColor,
    this.buttonHeight,
    this.buttonWidth,
    this.icon,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: buttonHeight ?? 50.h,
        width: buttonWidth?.w ?? double.maxFinite,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding?.w ?? 12.w,
          vertical: verticalPadding?.h ?? 6.h,
        ),
        decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 20.0),
          border: Border.all(
            color: borderColor ?? AppColors.whiteColor,
            width: borderWidth ?? 0,
          ),
        ),
        child: isLoading == true
            ? LoadingWidget(color: fourGroundColor ?? AppColors.whiteColor)
            : (icon == null
                  ? Text(buttonText, style: textStyle)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(buttonText, style: textStyle),
                        horizontalSpace(5),
                        Icon(icon, color: iconColor, size: 18.r),
                      ],
                    )),
      ),
      // ),
    );
  }
}
