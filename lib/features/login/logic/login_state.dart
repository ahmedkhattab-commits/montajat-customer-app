sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginValidationFailure extends LoginState {
  const LoginValidationFailure(this.messageKey);

  final String messageKey;
}

final class LoginReady extends LoginState {
  const LoginReady(this.phoneNumber);

  final String phoneNumber;
}
