sealed class OnboardingState {
  const OnboardingState({required this.currentPage});

  final int currentPage;
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial() : super(currentPage: 0);
}

final class OnboardingPageChanged extends OnboardingState {
  const OnboardingPageChanged({required super.currentPage});
}

final class OnboardingSaving extends OnboardingState {
  const OnboardingSaving({required super.currentPage});
}

final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted({required super.currentPage});
}

final class OnboardingFailure extends OnboardingState {
  const OnboardingFailure({
    required super.currentPage,
    required this.messageKey,
  });

  final String messageKey;
}
