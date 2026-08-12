import 'package:equatable/equatable.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';

enum ProfileLoadStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileLoadStatus.initial,
    this.profile,
    this.errorMessageKey,
  });

  final ProfileLoadStatus status;
  final ProfileModel? profile;
  final String? errorMessageKey;

  @override
  List<Object?> get props => [status, profile, errorMessageKey];
}
