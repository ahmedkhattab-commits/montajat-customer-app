sealed class VerificationState {
  const VerificationState({required this.secondsRemaining});

  final int secondsRemaining;
}

final class VerificationInitial extends VerificationState {
  const VerificationInitial({super.secondsRemaining = 119});
}

final class VerificationTimerRunning extends VerificationState {
  const VerificationTimerRunning({required super.secondsRemaining});
}

final class VerificationValidationFailure extends VerificationState {
  const VerificationValidationFailure({required super.secondsRemaining});
}

final class VerificationCodeAccepted extends VerificationState {
  const VerificationCodeAccepted({required super.secondsRemaining});
}
