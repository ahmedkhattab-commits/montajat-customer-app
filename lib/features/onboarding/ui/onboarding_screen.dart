import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/onboarding/data/models/onboarding_page_model.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_cubit.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_state.dart';
import 'package:montajat_customer_app/features/onboarding/ui/widgets/onboarding_actions.dart';
import 'package:montajat_customer_app/features/onboarding/ui/widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    OnboardingPageModel(
      descriptionKey: 'onboarding.pages.catalog',
      imageAsset: ImageAsset.onboardingCatalog,
      showLogo: true,
    ),
    OnboardingPageModel(
      descriptionKey: 'onboarding.pages.experience',
      imageAsset: ImageAsset.onboardingExperience,
      showLogo: true,
    ),
    OnboardingPageModel(
      descriptionKey: 'onboarding.pages.shopping',
      imageAsset: ImageAsset.onboardingShopping,
      showLogo: true,
    ),
  ];

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        } else if (state case OnboardingFailure(:final messageKey)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.tr(messageKey))));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    key: const ValueKey('onboarding-page-view'),
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: context.read<OnboardingCubit>().pageChanged,
                    itemBuilder: (context, index) => OnboardingPageContent(
                      page: _pages[index],
                      index: index,
                      pageCount: _pages.length,
                      currentPage: state.currentPage,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: OnboardingActions(
                    enabled: state is! OnboardingSaving,
                    onLogin: context.read<OnboardingCubit>().complete,
                    onCreateAccount: context.read<OnboardingCubit>().complete,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
