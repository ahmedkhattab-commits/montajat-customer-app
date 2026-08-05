import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:pinput/pinput.dart';

class VerificationCodeFields extends StatefulWidget {
  const VerificationCodeFields({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  State<VerificationCodeFields> createState() => _VerificationCodeFieldsState();
}

class _VerificationCodeFieldsState extends State<VerificationCodeFields> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 70.w,
      height: 70.h,
      textStyle: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.fieldBorder, width: 1),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        key: const ValueKey('verification-code-input'),
        length: 4,
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        defaultPinTheme: defaultTheme,
        focusedPinTheme: defaultTheme.copyWith(
          decoration: defaultTheme.decoration?.copyWith(
            border: Border.all(color: AppColors.focusedFieldBorder, width: 1),
          ),
        ),
        submittedPinTheme: defaultTheme,
        separatorBuilder: (_) => SizedBox(width: 20.w),
        preFilledWidget: Container(
          width: 34.w,
          height: 1.h,
          color: const Color(0xFFE7D6CC),
        ),
        cursor: Container(width: 1.w, height: 25.h, color: Colors.black),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        onChanged: widget.onChanged,
        onCompleted: widget.onChanged,
      ),
    );
  }
}
