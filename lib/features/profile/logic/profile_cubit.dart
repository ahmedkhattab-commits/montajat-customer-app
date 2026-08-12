import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/profile/data/repositories/profile_repository.dart';
import 'package:montajat_customer_app/features/profile/logic/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileRepository, this._authRepository)
    : super(const ProfileState());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  Future<void> loadProfile() async {
    emit(const ProfileState(status: ProfileLoadStatus.loading));
    try {
      final profile = await _profileRepository.getProfile();
      if (isClosed) return;
      emit(ProfileState(status: ProfileLoadStatus.success, profile: profile));
    } on ProfileException catch (error) {
      if (isClosed) return;
      emit(
        ProfileState(
          status: ProfileLoadStatus.failure,
          errorMessageKey: error.messageKey,
        ),
      );
    }
  }

  Future<void> logout() => _authRepository.logout();
}
