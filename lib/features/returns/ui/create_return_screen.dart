import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/app_constant.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/returns/logic/returns_cubit.dart';

class CreateReturnScreen extends StatefulWidget {
  const CreateReturnScreen({super.key});
  @override
  State<CreateReturnScreen> createState() => _CreateReturnScreenState();
}

class _CreateReturnScreenState extends State<CreateReturnScreen> {
  final _notes = TextEditingController();
  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      title: Text(context.tr('returns.create')),
      centerTitle: true,
      backgroundColor: Colors.white,
    ),
    body: BlocConsumer<ReturnsCubit, ReturnsState>(
      listener: (context, state) {
        if (state.error != null) {
          AppConstant.toast(context.tr(state.error!), false, context);
        }
      },
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _Label('returns.select_order'),
                DropdownButtonFormField<String>(
                  initialValue: state.selectedOrder,
                  decoration: _decoration(),
                  hint: Text(
                    context.tr(
                      state.loading
                          ? 'returns.loading_orders'
                          : 'returns.select_order_hint',
                    ),
                  ),
                  disabledHint: Text(
                    context.tr(
                      state.loading
                          ? 'returns.loading_orders'
                          : 'returns.no_eligible_orders',
                    ),
                  ),
                  items: state.orders
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.orderNumber,
                          child: Text(e.orderNumber),
                        ),
                      )
                      .toList(),
                  onChanged: state.loading || state.orders.isEmpty
                      ? null
                      : (value) {
                          if (value != null) {
                            context.read<ReturnsCubit>().selectOrder(value);
                          }
                        },
                ),
                if (!state.loading && state.orders.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('returns.no_eligible_orders_hint'),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: context.read<ReturnsCubit>().load,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(context.tr('returns.refresh')),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 18.h),
                _Label('returns.reason'),
                DropdownButtonFormField<Object>(
                  initialValue: state.selectedReason,
                  decoration: _decoration(),
                  items: state.reasons
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ReturnsCubit>().selectReason(value);
                    }
                  },
                ),
                SizedBox(height: 20.h),
                _Label('returns.products'),
                if (state.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.selectedOrder == null)
                  _Hint('returns.choose_order_hint')
                else if (state.lines.isEmpty)
                  _Hint('returns.no_eligible_lines')
                else
                  ...List.generate(state.lines.length, (i) {
                    final line = state.lines[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.name,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  line.itemCode,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: line.quantity > 0
                                    ? () => context
                                          .read<ReturnsCubit>()
                                          .changeQuantity(i, line.quantity - 1)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '${line.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                ),
                              ),
                              IconButton(
                                onPressed: line.quantity < line.maxQuantity
                                    ? () => context
                                          .read<ReturnsCubit>()
                                          .changeQuantity(i, line.quantity + 1)
                                    : null,
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.onboardingPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                SizedBox(height: 10.h),
                _Label('returns.notes'),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: _decoration(
                    hint: context.tr('returns.notes_hint'),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.onboardingPrimary,
                  minimumSize: Size.fromHeight(52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: state.submitting
                    ? null
                    : () async {
                        final result = await context
                            .read<ReturnsCubit>()
                            .submit(_notes.text.trim());
                        if (result != null && context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.returnDetails,
                            arguments: result.reference,
                          );
                        }
                      },
                child: state.submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.tr('returns.submit')),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.keyName);
  final String keyName;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      context.tr(keyName),
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.keyName);
  final String keyName;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      context.tr(keyName),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.grey),
    ),
  );
}

InputDecoration _decoration({String? hint}) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.r),
    borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
  ),
);
