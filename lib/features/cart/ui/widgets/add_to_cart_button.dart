import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/cart/data/repositories/cart_repository.dart';

class AddToCartButton extends StatefulWidget {
  const AddToCartButton({
    required this.itemCode,
    this.quantity = 1,
    this.enabled = true,
    super.key,
  });

  final String itemCode;
  final int quantity;
  final bool enabled;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: widget.enabled && !_loading ? _add : null,
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      backgroundColor: AppColors.onboardingPrimary,
      disabledBackgroundColor: widget.enabled
          ? AppColors.onboardingPrimary.withValues(alpha: .55)
          : const Color(0xFFFFF4D7),
      disabledForegroundColor: widget.enabled
          ? Colors.white
          : const Color(0xFFE4B532),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
    ),
    child: _loading
        ? SizedBox.square(
            dimension: 19.w,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : Text(
            context.tr(
              widget.enabled ? 'home.add_to_cart' : 'home.unavailable',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
  );

  Future<void> _add() async {
    setState(() => _loading = true);
    try {
      await getIt<CartRepository>().addItem(
        itemCode: widget.itemCode,
        quantity: widget.quantity,
      );
      if (!mounted) return;
      AppConstant.toast(context.tr('cart.added_successfully'), true, context);
    } on CartException catch (error) {
      if (!mounted) return;
      AppConstant.toast(context.tr(error.messageKey), false, context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
