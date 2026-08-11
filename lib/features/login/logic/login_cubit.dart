import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/login/logic/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginInitial());

  final AuthRepository _authRepository;

  Future<void> submit({
    required String dialCode,
    required String phoneNumber,
  }) async {
    if (state is LoginLoading) return;

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
    emit(const LoginLoading());
    try {
      await _authRepository.requestOtp(internationalPhone);
      emit(LoginOtpRequested(internationalPhone));
    } on AuthException catch (error) {
      emit(LoginRequestFailure(error.message));
    } on Object {
      emit(const LoginRequestFailure('auth_errors.invalid_response'));
    }
  }

  void clearValidation() {
    if (state is LoginValidationFailure || state is LoginRequestFailure) {
      emit(const LoginInitial());
    }
  }
}
