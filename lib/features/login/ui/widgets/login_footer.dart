import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({required this.onCreateAccount, super.key});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('login-create-account'),
      onTap: onCreateAccount,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${context.tr('login.no_account')} ',
                style: const TextStyle(color: Color(0xFF9F9F9F)),
              ),
              TextSpan(
                text: context.tr('login.create_account'),
                style: const TextStyle(color: Color(0xFFFFB900)),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
