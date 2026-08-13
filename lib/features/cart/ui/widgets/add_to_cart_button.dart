import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_cubit.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_state.dart';

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
  @override
  Widget build(BuildContext context) => BlocBuilder<CartCubit, CartState>(
    buildWhen: (previous, current) =>
        previous.cart != current.cart ||
        previous.mutatingItemCode != current.mutatingItemCode,
    builder: (context, state) {
      final item = state.cart?.items
          .where((item) => item.itemCode == widget.itemCode)
          .firstOrNull;
      final quantity = item?.quantity ?? 0;
      final loading = state.mutatingItemCode == widget.itemCode;

      if (quantity > 0) {
        return _QuantityControl(
          quantity: quantity,
          loading: loading,
          onAdd: () => context.read<CartCubit>().changeQuantity(
            widget.itemCode,
            quantity + widget.quantity,
          ),
          onRemove: () => quantity <= widget.quantity
              ? context.read<CartCubit>().removeItem(widget.itemCode)
              : context.read<CartCubit>().changeQuantity(
                  widget.itemCode,
                  quantity - widget.quantity,
                ),
        );
      }

      return FilledButton(
        onPressed: widget.enabled && !loading ? _add : null,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          backgroundColor: AppColors.onboardingPrimary,
          disabledBackgroundColor: widget.enabled
              ? AppColors.onboardingPrimary.withValues(alpha: .55)
              : const Color(0xFFFFF4D7),
          disabledForegroundColor: widget.enabled
              ? Colors.white
              : const Color(0xFFE4B532),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        child: loading
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
    },
  );

  Future<void> _add() async {
    final added = await context.read<CartCubit>().addItem(
      widget.itemCode,
      quantity: widget.quantity,
    );
    if (!mounted) return;
    if (added) {
      AppConstant.toast(context.tr('cart.added_successfully'), true, context);
    } else {
      final error = context.read<CartCubit>().state.errorMessageKey;
      if (error != null) {
        AppConstant.toast(context.tr(error), false, context);
      }
    }
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.loading,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final bool loading;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5FA),
      borderRadius: BorderRadius.circular(5.r),
    ),
    child: Row(
      children: [
        Expanded(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: loading ? null : onRemove,
            icon: Icon(
              quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
              size: 19.sp,
              color: quantity == 1
                  ? const Color(0xFFFF5151)
                  : AppColors.onboardingPrimary,
            ),
          ),
        ),
        SizedBox(
          width: 34.w,
          child: Center(
            child: loading
                ? SizedBox.square(
                    dimension: 17.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '$quantity',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        Expanded(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: loading ? null : onAdd,
            icon: Icon(
              Icons.add,
              size: 19.sp,
              color: AppColors.onboardingPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
