import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/registration/data/repositories/registration_repository.dart';

enum RegistrationStatus { initial, loading, success, failure }

class RegistrationState {
  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.error,
  });
  final RegistrationStatus status;
  final String? error;
}

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._repository) : super(const RegistrationState());
  final RegistrationRepository _repository;

  Future<void> submit(Map<String, dynamic> data) async {
    if (state.status == RegistrationStatus.loading) return;
    emit(const RegistrationState(status: RegistrationStatus.loading));
    try {
      await _repository.submit(data);
      emit(const RegistrationState(status: RegistrationStatus.success));
    } on RegistrationException catch (error) {
      emit(
        RegistrationState(
          status: RegistrationStatus.failure,
          error: error.message,
        ),
      );
    }
  }
}
