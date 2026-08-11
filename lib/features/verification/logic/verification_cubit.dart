import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit(this._authRepository) : super(const VerificationInitial());

  final AuthRepository _authRepository;
  Timer? _timer;
  int _secondsRemaining = 119;

  void startTimer({int seconds = 119}) {
    _timer?.cancel();
    _secondsRemaining = seconds;
    emit(VerificationTimerRunning(secondsRemaining: _secondsRemaining));
    if (_secondsRemaining <= 0) return;
    _runTimer();
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        if (state is! VerificationSubmitting &&
            state is! VerificationResending) {
          emit(const VerificationTimerRunning(secondsRemaining: 0));
        }
        return;
      }
      if (state is! VerificationSubmitting && state is! VerificationResending) {
        emit(VerificationTimerRunning(secondsRemaining: _secondsRemaining));
      }
    });
  }

  Future<void> confirm({required String mobile, required String code}) async {
    if (state is VerificationSubmitting || state is VerificationResending) {
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(code)) {
      emit(VerificationValidationFailure(secondsRemaining: _secondsRemaining));
      return;
    }

    emit(VerificationSubmitting(secondsRemaining: _secondsRemaining));
    try {
      await _authRepository.verifyOtp(mobile: mobile, code: code);
      emit(VerificationCodeAccepted(secondsRemaining: _secondsRemaining));
    } on AuthException catch (error) {
      emit(
        VerificationRequestFailure(
          message: error.message,
          secondsRemaining: _secondsRemaining,
        ),
      );
    } on Object {
      emit(
        VerificationRequestFailure(
          message: 'auth_errors.invalid_response',
          secondsRemaining: _secondsRemaining,
        ),
      );
    }
  }

  Future<void> resend(String mobile) async {
    if (_secondsRemaining > 0 ||
        state is VerificationSubmitting ||
        state is VerificationResending) {
      return;
    }

    emit(const VerificationResending(secondsRemaining: 0));
    try {
      await _authRepository.requestOtp(mobile);
      _secondsRemaining = 119;
      emit(VerificationResent(secondsRemaining: _secondsRemaining));
      _runTimer();
    } on AuthException catch (error) {
      emit(
        VerificationRequestFailure(
          message: error.message,
          secondsRemaining: _secondsRemaining,
        ),
      );
    } on Object {
      emit(
        VerificationRequestFailure(
          message: 'auth_errors.invalid_response',
          secondsRemaining: _secondsRemaining,
        ),
      );
    }
  }

  void clearValidation() {
    if (state is VerificationValidationFailure ||
        state is VerificationRequestFailure) {
      emit(VerificationTimerRunning(secondsRemaining: _secondsRemaining));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
