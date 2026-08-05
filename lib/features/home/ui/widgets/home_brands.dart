import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_section_header.dart';

class HomeNewArrivalsBrands extends StatelessWidget {
  const HomeNewArrivalsBrands({super.key});

  static const _assets = [
    ImageAsset.brandJosi,
    ImageAsset.brandEspree,
    ImageAsset.brandFelineGo,
    ImageAsset.brandGoDog,
    ImageAsset.brandSignorGatto,
    ImageAsset.brandSimpleSolution,
  ];

  @override
  Widget build(BuildContext context) => const HomeBrandGrid(
    key: ValueKey('home-new-arrivals-brands'),
    titleKey: 'home.new_arrivals',
    assets: _assets,
  );
}

class HomeBrands extends StatelessWidget {
  const HomeBrands({super.key});

  static const _assets = [
    ImageAsset.brandArabian,
    ImageAsset.brandProfine,
    ImageAsset.brandAfp,
    ImageAsset.brandButchers,
    ImageAsset.brandStefplast,
    ImageAsset.brandSanal,
  ];

  @override
  Widget build(BuildContext context) =>
      const HomeBrandGrid(titleKey: 'home.brands', assets: _assets);
}

class HomeBrandGrid extends StatelessWidget {
  const HomeBrandGrid({
    required this.titleKey,
    required this.assets,
    super.key,
  });

  final String titleKey;
  final List<String> assets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionHeader(titleKey: titleKey),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: assets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 120 / 90,
            ),
            itemBuilder: (_, index) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE8E8E8)),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(assets[index], fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}
