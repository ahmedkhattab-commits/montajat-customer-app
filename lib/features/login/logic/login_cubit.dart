import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/login/logic/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginInitial());

  void submit({required String dialCode, required String phoneNumber}) {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final isSaudiNumber = dialCode == '+966';
    final isValid = isSaudiNumber
        ? RegExp(r'^05\d{8}$').hasMatch(normalizedPhone)
        : normalizedPhone.length >= 6 && normalizedPhone.length <= 12;

    if (!isValid) {
      emit(const LoginValidationFailure('login.phone_error'));
      return;
    }

    final internationalPhone = normalizedPhone.startsWith('0')
        ? '$dialCode${normalizedPhone.substring(1)}'
        : '$dialCode$normalizedPhone';
    emit(LoginReady(internationalPhone));
  }

  void clearValidation() {
    if (state is LoginValidationFailure) emit(const LoginInitial());
  }
}
