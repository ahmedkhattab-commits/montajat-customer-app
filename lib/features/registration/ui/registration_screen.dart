import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/registration/logic/registration_cubit.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(9, (_) => TextEditingController());

  static const _fields = [
    ('business_name', 'registration.business_name', TextInputType.text),
    ('contact_name', 'registration.contact_name', TextInputType.name),
    ('mobile', 'registration.mobile', TextInputType.phone),
    ('email', 'registration.email', TextInputType.emailAddress),
    ('vat_number', 'registration.vat_number', TextInputType.number),
    ('cr_number', 'registration.cr_number', TextInputType.number),
    ('city', 'registration.city', TextInputType.text),
    ('address', 'registration.address', TextInputType.streetAddress),
    ('notes', 'registration.notes', TextInputType.multiline),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<RegistrationCubit, RegistrationState>(
    listener: (context, state) {
      if (state.status == RegistrationStatus.success) {
        AppConstant.toast(context.tr('registration.success'), true, context);
        Navigator.pop(context);
      } else if (state.status == RegistrationStatus.failure) {
        final message = state.error ?? 'auth_errors.request_failed';
        AppConstant.toast(
          message.contains('.') ? context.tr(message) : message,
          false,
          context,
        );
      }
    },
    builder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(context.tr('registration.title')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 30.h),
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FC),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    color: AppColors.onboardingPrimary,
                    size: 30.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      context.tr('registration.hint'),
                      style: TextStyle(fontSize: 13.sp, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            ...List.generate(_fields.length, (index) {
              final field = _fields[index];
              final optional = field.$1 == 'notes';
              return Padding(
                padding: EdgeInsets.only(bottom: 13.h),
                child: TextFormField(
                  controller: _controllers[index],
                  keyboardType: field.$3,
                  maxLines: optional ? 3 : 1,
                  validator: optional
                      ? null
                      : (value) => value?.trim().isEmpty == true
                            ? context.tr('registration.required')
                            : null,
                  decoration: InputDecoration(
                    labelText: context.tr(field.$2),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 8.h),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.onboardingPrimary,
                minimumSize: Size.fromHeight(54.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: state.status == RegistrationStatus.loading
                  ? null
                  : _submit,
              child: state.status == RegistrationStatus.loading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.tr('registration.submit')),
            ),
          ],
        ),
      ),
    ),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegistrationCubit>().submit({
      for (var index = 0; index < _fields.length; index++)
        _fields[index].$1: _controllers[index].text.trim(),
    });
  }
}
