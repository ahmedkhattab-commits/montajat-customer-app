import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/brand_card.dart';

class BrandsScreenArguments {
  const BrandsScreenArguments({required this.title, required this.brands});

  final String title;
  final List<HomeBrandModel> brands;
}

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({required this.arguments, super.key});

  final BrandsScreenArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('brands-screen'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 74.h,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          arguments.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GridView.builder(
        key: const ValueKey('all-brands-grid'),
        padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 30.h),
        itemCount: arguments.brands.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 120 / 90,
        ),
        itemBuilder: (_, index) => BrandCard(
          brand: arguments.brands[index],
          keyPrefix: 'all-brand-products',
        ),
      ),
    );
  }
}
