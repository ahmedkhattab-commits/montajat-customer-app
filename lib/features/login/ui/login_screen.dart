import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/login/logic/login_cubit.dart';
import 'package:montajat_customer_app/features/login/logic/login_state.dart';
import 'package:montajat_customer_app/features/login/ui/widgets/login_footer.dart';
import 'package:montajat_customer_app/features/login/ui/widgets/login_header.dart';
import 'package:montajat_customer_app/features/login/ui/widgets/phone_number_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _dialCode = '+966';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginReady) {
          Navigator.of(
            context,
          ).pushNamed(Routes.verification, arguments: state.phoneNumber);
        }
      },
      builder: (context, state) {
        final errorKey = state is LoginValidationFailure
            ? state.messageKey
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 18.h),
                        const LoginHeader(),
                        SizedBox(height: 28.h),
                        PhoneNumberField(
                          controller: _phoneController,
                          errorKey: errorKey,
                          onChanged: (_) =>
                              context.read<LoginCubit>().clearValidation(),
                          onCountryChanged: (country) {
                            setState(
                              () => _dialCode = country.dialCode ?? '+966',
                            );
                            context.read<LoginCubit>().clearValidation();
                          },
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          height: 60.h,
                          child: FilledButton(
                            key: const ValueKey('login-submit'),
                            onPressed: () => context.read<LoginCubit>().submit(
                              dialCode: _dialCode,
                              phoneNumber: _phoneController.text,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.onboardingPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.r),
                              ),
                            ),
                            child: Text(
                              context.tr('login.submit'),
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        LoginFooter(onCreateAccount: () {}),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
