import '../../exceptions/failure.dart';

class RegisterError extends Failure {
  const RegisterError({required super.message});

  factory RegisterError.fromJson(Map<String, dynamic> json) {
    return RegisterError(message: json["message"]);
  }
}
