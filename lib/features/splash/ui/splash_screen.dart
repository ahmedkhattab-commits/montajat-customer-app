import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/splash/data/models/splash_content_model.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_cubit.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _content = SplashContentModel.defaultContent;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state case SplashCompleted(shouldOpenLanguageSelection: true)) {
            Navigator.of(
              context,
            ).pushReplacementNamed(Routes.languageSelection);
          } else if (state case SplashCompleted(shouldOpenOnboarding: true)) {
            Navigator.of(context).pushReplacementNamed(Routes.onboarding);
          } else if (state case SplashCompleted(shouldOpenLogin: true)) {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        },
        child: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              opacity: state is SplashVisible || state is SplashCompleted
                  ? 1
                  : 0,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _content.designWidth,
                    height: _content.designHeight,
                    child: Image.asset(
                      _content.assetPath,
                      key: const ValueKey('splash-design'),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
