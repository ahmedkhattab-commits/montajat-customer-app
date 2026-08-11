import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this.shouldOpenLanguageSelection,
    required this.shouldOpenOnboarding,
    required this.shouldOpenLogin,
    required this.hasActiveSession,
  }) : super(const SplashInitial());

  final bool shouldOpenLanguageSelection;
  final bool shouldOpenOnboarding;
  final bool shouldOpenLogin;
  final Future<bool> Function() hasActiveSession;

  Future<void> start() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (isClosed) return;
    emit(const SplashVisible());
    await Future<void>.delayed(const Duration(milliseconds: 1820));
    if (!isClosed) {
      final shouldOpenHome = shouldOpenLogin && await hasActiveSession();
      if (isClosed) return;
      emit(
        SplashCompleted(
          shouldOpenLanguageSelection: shouldOpenLanguageSelection,
          shouldOpenOnboarding: shouldOpenOnboarding,
          shouldOpenLogin: shouldOpenLogin && !shouldOpenHome,
          shouldOpenHome: shouldOpenHome,
        ),
      );
    }
  }
}
