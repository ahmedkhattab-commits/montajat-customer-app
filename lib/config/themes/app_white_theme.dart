import 'package:flutter/material.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';

ThemeData appWhiteTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.background,
    ),
    fontFamily: 'IBMPlexSansArabic',
  );
}
