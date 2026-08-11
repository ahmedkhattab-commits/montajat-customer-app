sealed class SplashState {
  const SplashState();
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashVisible extends SplashState {
  const SplashVisible();
}

final class SplashCompleted extends SplashState {
  const SplashCompleted({
    required this.shouldOpenLanguageSelection,
    required this.shouldOpenOnboarding,
    required this.shouldOpenLogin,
    required this.shouldOpenHome,
  });

  final bool shouldOpenLanguageSelection;
  final bool shouldOpenOnboarding;
  final bool shouldOpenLogin;
  final bool shouldOpenHome;
}
