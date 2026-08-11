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

final class VerificationSubmitting extends VerificationState {
  const VerificationSubmitting({required super.secondsRemaining});
}

final class VerificationCodeAccepted extends VerificationState {
  const VerificationCodeAccepted({required super.secondsRemaining});
}

final class VerificationResending extends VerificationState {
  const VerificationResending({required super.secondsRemaining});
}

final class VerificationResent extends VerificationState {
  const VerificationResent({required super.secondsRemaining});
}

final class VerificationRequestFailure extends VerificationState {
  const VerificationRequestFailure({
    required this.message,
    required super.secondsRemaining,
  });

  final String message;
}
