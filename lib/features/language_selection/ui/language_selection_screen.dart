import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/language_selection/data/models/language_option_model.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_cubit.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_state.dart';
import 'package:montajat_customer_app/features/language_selection/ui/widgets/language_option_card.dart';
import 'package:montajat_customer_app/features/language_selection/ui/widgets/language_selection_header.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const _languages = [
    LanguageOptionModel(
      code: 'ar',
      labelKey: 'language_selection.languages.arabic',
      flagAsset: ImageAsset.saudiArabiaFlag,
    ),
    LanguageOptionModel(
      code: 'en',
      labelKey: 'language_selection.languages.english',
      flagAsset: ImageAsset.unitedStatesFlag,
    ),
    LanguageOptionModel(
      code: 'ur',
      labelKey: 'language_selection.languages.urdu',
      flagAsset: ImageAsset.indiaFlag,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageSelectionCubit, LanguageSelectionState>(
      listener: (context, state) async {
        if (state case LanguageSelectionSaved(:final selectedLanguageCode?)) {
          await context.setLocale(Locale(selectedLanguageCode));
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(Routes.onboarding, (_) => false);
          }
        } else if (state case LanguageSelectionFailure(:final messageKey)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.tr(messageKey))));
        }
      },
      builder: (context, state) {
        final isEnabled = state is! LanguageSelectionSaving;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 94.h),
                  const LanguageSelectionHeader(),
                  SizedBox(height: 22.89.h),
                  for (var index = 0; index < _languages.length; index++) ...[
                    LanguageOptionCard(
                      option: _languages[index],
                      enabled: isEnabled,
                      onTap: () => context
                          .read<LanguageSelectionCubit>()
                          .selectLanguage(_languages[index].code),
                    ),
                    if (index != _languages.length - 1) SizedBox(height: 15.h),
                  ],
                  const Spacer(),
                  Text(
                    context.tr('language_selection.footer'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.tr('language_selection.footer_hint'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.languageFooter,
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
