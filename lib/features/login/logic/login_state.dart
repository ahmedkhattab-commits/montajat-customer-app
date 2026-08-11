sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginValidationFailure extends LoginState {
  const LoginValidationFailure(this.messageKey);

  final String messageKey;
}

final class LoginOtpRequested extends LoginState {
  const LoginOtpRequested(this.phoneNumber);

  final String phoneNumber;
}

final class LoginRequestFailure extends LoginState {
  const LoginRequestFailure(this.message);

  final String message;
}
