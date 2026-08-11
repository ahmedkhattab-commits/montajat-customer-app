import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/features/categories/logic/categories_cubit.dart';
import 'package:montajat_customer_app/features/categories/ui/categories_screen.dart';
import 'package:montajat_customer_app/features/language_selection/data/repositories/language_repository.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_cubit.dart';
import 'package:montajat_customer_app/features/language_selection/ui/language_selection_screen.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';
import 'package:montajat_customer_app/features/home/ui/home_screen.dart';
import 'package:montajat_customer_app/features/login/logic/login_cubit.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/login/ui/login_screen.dart';
import 'package:montajat_customer_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_cubit.dart';
import 'package:montajat_customer_app/features/onboarding/ui/onboarding_screen.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_cubit.dart';
import 'package:montajat_customer_app/features/splash/ui/splash_screen.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_cubit.dart';
import 'package:montajat_customer_app/features/verification/ui/verification_screen.dart';

abstract final class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => _createSplashCubit()..start(),
            child: const SplashScreen(),
          ),
        );
      case Routes.languageSelection:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => LanguageSelectionCubit(const LanguageRepository()),
            child: const LanguageSelectionScreen(),
          ),
        );
      case Routes.onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => OnboardingCubit(const OnboardingRepository()),
            child: const OnboardingScreen(),
          ),
        );
      case Routes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => LoginCubit(getIt<AuthRepository>()),
            child: const LoginScreen(),
          ),
        );
      case Routes.verification:
        final phoneNumber = settings.arguments as String? ?? '';
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                VerificationCubit(getIt<AuthRepository>())..startTimer(),
            child: VerificationScreen(phoneNumber: phoneNumber),
          ),
        );
      case Routes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => HomeCubit(getIt<HomeRepository>())..loadHome(),
            child: const HomeScreen(),
          ),
        );
      case Routes.categories:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => CategoriesCubit(),
            child: CategoriesScreen(standalone: settings.arguments == true),
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => _createSplashCubit()..start(),
            child: const SplashScreen(),
          ),
        );
    }
  }

  static SplashCubit _createSplashCubit() {
    final hasSelectedLanguage =
        CacheHelper.getString(ConstantKeys.selectedLanguageCode) != null;
    final hasCompletedOnboarding = const OnboardingRepository().isCompleted;

    return SplashCubit(
      shouldOpenLanguageSelection: !hasSelectedLanguage,
      shouldOpenOnboarding: hasSelectedLanguage && !hasCompletedOnboarding,
      shouldOpenLogin: hasSelectedLanguage && hasCompletedOnboarding,
      hasActiveSession: getIt<AuthRepository>().hasActiveSession,
    );
  }
}
