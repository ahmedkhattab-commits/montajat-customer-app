import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(const OnboardingInitial());

  final OnboardingRepository _repository;

  void pageChanged(int page) {
    if (state is OnboardingSaving) return;
    emit(OnboardingPageChanged(currentPage: page));
  }

  Future<void> complete() async {
    if (state is OnboardingSaving || state is OnboardingCompleted) return;

    final currentPage = state.currentPage;
    emit(OnboardingSaving(currentPage: currentPage));
    try {
      await _repository.complete();
      if (!isClosed) emit(OnboardingCompleted(currentPage: currentPage));
    } on Object {
      if (!isClosed) {
        emit(
          OnboardingFailure(
            currentPage: currentPage,
            messageKey: 'onboarding.save_error',
          ),
        );
      }
    }
  }
}
