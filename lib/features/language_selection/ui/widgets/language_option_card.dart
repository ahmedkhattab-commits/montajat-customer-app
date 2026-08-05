import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/language_selection/data/models/language_option_model.dart';

class LanguageOptionCard extends StatelessWidget {
  const LanguageOptionCard({
    required this.option,
    required this.onTap,
    required this.enabled,
    super.key,
  });

  final LanguageOptionModel option;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = context.tr(option.labelKey);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          key: ValueKey('language-${option.code}'),
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: 380.w,
            height: 70.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.fieldBorder, width: 1),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(2, 4),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 15.w,
                  top: 20.5.h,
                  child: Container(
                    width: 31.w,
                    height: 29.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.languageAccent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Image.asset(
                      ImageAsset.languageBackArrow,
                      width: 15.w,
                      height: 15.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  left: 55.7.w,
                  top: 18.5.h,
                  child: SizedBox(
                    width: 231.8.w,
                    height: 23.h,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 297.5.w,
                  top: 19.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: Image.asset(
                      option.flagAsset,
                      width: 42.w,
                      height: 30.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
