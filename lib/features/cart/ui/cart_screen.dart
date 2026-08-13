import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/cart/data/models/cart_model.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_cubit.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_state.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/home/ui/widgets/home_bottom_navigation.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('cart-screen'),
    backgroundColor: Colors.white,
    appBar: AppBar(
      toolbarHeight: 72.h,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        context.tr('cart.title'),
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) => IconButton(
            key: const ValueKey('clear-cart'),
            tooltip: context.tr('cart.clear'),
            onPressed: state.cart?.isEmpty != false || state.clearing
                ? null
                : () => _confirmClear(context),
            icon: state.clearing
                ? SizedBox.square(
                    dimension: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_sweep_outlined),
          ),
        ),
        SizedBox(width: 8.w),
      ],
    ),
    body: BlocConsumer<CartCubit, CartState>(
      listenWhen: (previous, current) =>
          previous.errorMessageKey != current.errorMessageKey ||
          previous.createdOrderNumber != current.createdOrderNumber,
      listener: (context, state) {
        if (state.errorMessageKey != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr(state.errorMessageKey!))),
          );
        }
        if (state.createdOrderNumber != null) {
          Navigator.of(context).pushReplacementNamed(
            Routes.orderDetails,
            arguments: state.createdOrderNumber,
          );
        }
      },
      builder: (context, state) {
        if (state.loadStatus == CartLoadStatus.initial ||
            state.loadStatus == CartLoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.loadStatus == CartLoadStatus.failure || state.cart == null) {
          return _CartError(messageKey: state.errorMessageKey);
        }
        if (state.cart!.isEmpty) return const _EmptyCart();
        return _CartContent(cart: state.cart!);
      },
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final cart = state.cart;
            if (cart == null || cart.isEmpty) return const SizedBox.shrink();
            return _CheckoutBar(cart: cart);
          },
        ),
        const HomeBottomNavigation(currentIndex: 2),
      ],
    ),
  );

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('cart.clear')),
        content: Text(context.tr('cart.clear_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('profile.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE95353),
            ),
            child: Text(context.tr('cart.clear')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CartCubit>().clearCart();
    }
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.cart});
  final CartModel cart;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: AppColors.onboardingPrimary,
    onRefresh: context.read<CartCubit>().loadCart,
    child: ListView(
      key: const ValueKey('cart-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 28.h),
      children: [
        _DeliveryCard(cart: cart),
        SizedBox(height: 22.h),
        _SectionTitle(title: context.tr('cart.products')),
        SizedBox(height: 10.h),
        ...cart.items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _CartItemCard(item: item),
          ),
        ),
        SizedBox(height: 10.h),
        _SummaryCard(cart: cart),
      ],
    ),
  );
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.cart});
  final CartModel cart;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE8E8E8)),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.onboardingPrimary,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  context.tr('cart.delivery_details'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('edit-cart-delivery'),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BlocProvider.value(
                    value: context.read<CartCubit>(),
                    child: _DeliverySheet(cart: cart),
                  ),
                ),
                child: Text(context.tr('cart.edit')),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEFEFEF)),
        _DetailRow(
          label: context.tr('cart.delivery_address'),
          value: cart.shipToCode ?? '-',
        ),
        _DetailRow(
          label: context.tr('cart.delivery_date'),
          value: cart.requestedDeliveryDate == null
              ? '-'
              : DateFormat('yyyy/MM/dd').format(cart.requestedDeliveryDate!),
        ),
        _DetailRow(
          label: context.tr('cart.delivery_notes'),
          value: cart.deliveryNotes ?? '-',
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: const Color(0xFF999999), fontSize: 12.sp),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) =>
          previous.mutatingItemCode != current.mutatingItemCode,
      builder: (context, state) {
        final loading = state.mutatingItemCode == item.itemCode;
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8E8E8)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 78.w,
                height: 88.h,
                child: item.imageUrl == null
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFFD8D8D8),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (_, _) =>
                            const ColoredBox(color: Color(0xFFFAFAFA)),
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.localizedName(languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _packageText(context),
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          '${item.lineTotal.toStringAsFixed(2)} ${item.currency}',
                          style: TextStyle(
                            color: const Color(0xFFE95353),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (loading)
                          SizedBox.square(
                            dimension: 24.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        else
                          _QuantityControl(item: item),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _packageText(BuildContext context) => item.unitsPerCarton == null
      ? item.uom ?? item.itemCode
      : context.tr(
          'products_listing.units_per_carton',
          namedArgs: {'count': '${item.unitsPerCarton}'},
        );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _SquareButton(
        key: ValueKey('remove-cart-item-${item.itemCode}'),
        color: const Color(0xFFFF4D5A),
        icon: item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
        onPressed: item.quantity == 1
            ? () => context.read<CartCubit>().removeItem(item.itemCode)
            : () => context.read<CartCubit>().changeQuantity(
                item.itemCode,
                item.quantity - 1,
              ),
      ),
      Container(
        width: 46.w,
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Text(
          '${item.quantity}',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
        ),
      ),
      _SquareButton(
        key: ValueKey('increment-cart-item-${item.itemCode}'),
        color: const Color(0xFFEAF1FA),
        iconColor: AppColors.onboardingPrimary,
        icon: Icons.add,
        onPressed: () => context.read<CartCubit>().changeQuantity(
          item.itemCode,
          item.quantity + 1,
        ),
      ),
    ],
  );
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.color,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    super.key,
  });
  final Color color;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 42.w,
    height: 38.h,
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(4.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.r),
        child: Icon(icon, color: iconColor, size: 20.sp),
      ),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cart});
  final CartModel cart;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 7.h),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE8E8E8)),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.onboardingPrimary,
              ),
              SizedBox(width: 7.w),
              Text(
                context.tr('cart.summary'),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFEFEFEF)),
        _SummaryRow(
          label: context.tr('cart.items_count'),
          value: '${cart.itemsCount}',
        ),
        _SummaryRow(
          label: context.tr('cart.subtotal'),
          value: _money(cart.subtotal),
        ),
        _SummaryRow(
          label: context.tr('cart.vat'),
          value: _money(cart.vatAmount),
        ),
        _SummaryRow(
          label: context.tr('cart.discount'),
          value: _money(cart.discountAmount),
        ),
        const Divider(color: Color(0xFFEFEFEF)),
        _SummaryRow(
          label: context.tr('cart.total'),
          value: _money(cart.total),
          bold: true,
        ),
      ],
    ),
  );

  String _money(num value) => '${value.toStringAsFixed(2)} ${cart.currency}';
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? Colors.black : const Color(0xFF888888),
              fontSize: bold ? 16.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16.sp : 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});
  final CartModel cart;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 54.h,
        child: FilledButton(
          key: const ValueKey('cart-checkout'),
          onPressed: context.read<CartCubit>().checkout,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.onboardingPrimary,
            disabledBackgroundColor: AppColors.onboardingPrimary,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          child: context.watch<CartCubit>().state.checkingOut
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  '${context.tr('cart.checkout')}  •  ${cart.total.toStringAsFixed(2)} ${cart.currency}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    ),
  );
}

class _DeliverySheet extends StatefulWidget {
  const _DeliverySheet({required this.cart});
  final CartModel cart;
  @override
  State<_DeliverySheet> createState() => _DeliverySheetState();
}

class _DeliverySheetState extends State<_DeliverySheet> {
  late final TextEditingController _address;
  late final TextEditingController _notes;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(text: widget.cart.shipToCode);
    _notes = TextEditingController(text: widget.cart.deliveryNotes);
    _date =
        widget.cart.requestedDeliveryDate ??
        DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      22.w,
      18.h,
      22.w,
      MediaQuery.viewInsetsOf(context).bottom + 24.h,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('cart.delivery_details'),
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 18.h),
        TextField(
          controller: _address,
          decoration: InputDecoration(
            labelText: context.tr('cart.delivery_address'),
            border: const OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12.h),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(DateFormat('yyyy/MM/dd').format(_date)),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('cart.delivery_notes'),
            border: const OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 18.h),
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) => FilledButton(
            onPressed: state.savingDelivery ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(52.h),
              backgroundColor: AppColors.onboardingPrimary,
            ),
            child: state.savingDelivery
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(context.tr('cart.save_delivery')),
          ),
        ),
      ],
    ),
  );

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _save() async {
    final shipToCode = _address.text.trim();
    if (shipToCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('cart.address_required'))),
      );
      return;
    }
    final saved = await context.read<CartCubit>().updateDelivery(
      shipToCode: shipToCode,
      requestedDeliveryDate: _date,
      deliveryNotes: _notes.text,
    );
    if (saved && mounted) Navigator.pop(context);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: context.read<CartCubit>().loadCart,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 230.h),
        Icon(
          Icons.remove_shopping_cart_outlined,
          size: 70.sp,
          color: const Color(0xFFD0D0D0),
        ),
        SizedBox(height: 14.h),
        Text(
          context.tr('cart.empty'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _CartError extends StatelessWidget {
  const _CartError({this.messageKey});
  final String? messageKey;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr(messageKey ?? 'auth_errors.request_failed')),
        IconButton(
          onPressed: context.read<CartCubit>().loadCart,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
  );
}
