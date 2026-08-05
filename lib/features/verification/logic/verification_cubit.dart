import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit() : super(const VerificationInitial());

  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    emit(const VerificationTimerRunning(secondsRemaining: 119));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        emit(const VerificationTimerRunning(secondsRemaining: 0));
        return;
      }
      emit(VerificationTimerRunning(secondsRemaining: remaining));
    });
  }

  void confirm(String code) {
    if (!RegExp(r'^\d{4}$').hasMatch(code)) {
      emit(
        VerificationValidationFailure(secondsRemaining: state.secondsRemaining),
      );
      return;
    }
    emit(VerificationCodeAccepted(secondsRemaining: state.secondsRemaining));
  }

  void clearValidation() {
    if (state is VerificationValidationFailure) {
      emit(VerificationTimerRunning(secondsRemaining: state.secondsRemaining));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
