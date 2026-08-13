import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/addresses/data/models/address_model.dart';
import 'package:montajat_customer_app/features/addresses/logic/address_details_cubit.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _district = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();
  final _postal = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  String? _cityCode;
  bool _initialized = false;

  @override
  void dispose() {
    for (final controller in [
      _label,
      _district,
      _street,
      _building,
      _postal,
      _contact,
      _phone,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('address-details-screen'),
    backgroundColor: const Color(0xFFF8F8F8),
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      title: Text(
        context.tr('addresses.details'),
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: BlocConsumer<AddressDetailsCubit, AddressDetailsState>(
      listener: (_, state) {
        if (!_initialized && state.address != null) {
          _fill(state.address!);
          _initialized = true;
        }
      },
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.address == null) {
          return Center(
            child: Text(
              context.tr(state.errorMessageKey ?? 'addresses.not_found'),
            ),
          );
        }
        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 34.h),
            children: [
              _AddressSummary(address: state.address!),
              SizedBox(height: 18.h),
              _Field(controller: _label, labelKey: 'addresses.label'),
              if (state.cities.isNotEmpty) ...[
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: state.cities.any((c) => c.code == _cityCode)
                      ? _cityCode
                      : null,
                  decoration: _decoration(context, 'addresses.city'),
                  items: state.cities
                      .map(
                        (city) => DropdownMenuItem(
                          value: city.code,
                          child: Text(city.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => _cityCode = value,
                ),
                SizedBox(height: 12.h),
              ],
              _Field(controller: _district, labelKey: 'addresses.district'),
              _Field(controller: _street, labelKey: 'addresses.street'),
              _Field(
                controller: _building,
                labelKey: 'addresses.building_number',
              ),
              _Field(controller: _postal, labelKey: 'addresses.postal_code'),
              _Field(
                controller: _contact,
                labelKey: 'addresses.contact_person',
              ),
              _Field(
                controller: _phone,
                labelKey: 'addresses.phone',
                keyboardType: TextInputType.phone,
              ),
              _Field(
                controller: _notes,
                labelKey: 'addresses.notes',
                maxLines: 3,
              ),
              SizedBox(height: 8.h),
              FilledButton(
                key: const ValueKey('save-address'),
                onPressed: state.saving ? null : () => _save(state.address!),
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(52.h),
                  backgroundColor: AppColors.onboardingPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
                child: state.saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(context.tr('addresses.save')),
              ),
            ],
          ),
        );
      },
    ),
  );

  void _fill(AddressModel address) {
    _label.text = address.label;
    _cityCode = address.cityCode;
    _district.text = address.district ?? '';
    _street.text = address.street ?? '';
    _building.text = address.buildingNumber ?? '';
    _postal.text = address.postalCode ?? '';
    _contact.text = address.contactPerson ?? '';
    _phone.text = address.phone ?? '';
    _notes.text = address.notes ?? '';
  }

  Future<void> _save(AddressModel current) async {
    if (_formKey.currentState?.validate() != true) return;
    final updated = AddressModel(
      id: current.id,
      label: _label.text.trim(),
      city: current.city,
      cityCode: _cityCode ?? current.cityCode,
      district: _nullable(_district.text),
      street: _nullable(_street.text),
      buildingNumber: _nullable(_building.text),
      postalCode: _nullable(_postal.text),
      contactPerson: _nullable(_contact.text),
      phone: _nullable(_phone.text),
      notes: _nullable(_notes.text),
      isPreferred: current.isPreferred,
      code: current.code,
      typeLabel: current.typeLabel,
      state: current.state,
      country: current.country,
      formatted: current.formatted,
      isSapDefault: current.isSapDefault,
      isHidden: current.isHidden,
    );
    final saved = await context.read<AddressDetailsCubit>().save(updated);
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();
}

class _AddressSummary extends StatelessWidget {
  const _AddressSummary({required this.address});
  final AddressModel address;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8E8E8)),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFFFF5DC),
          child: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFF5B335),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.code ?? address.label,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5.h),
              Text(
                address.formatted ?? '-',
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: 12.sp,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.labelKey,
    this.keyboardType,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String labelKey;
  final TextInputType? keyboardType;
  final int maxLines;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _decoration(context, labelKey),
      validator: labelKey == 'addresses.label'
          ? (value) => value?.trim().isEmpty == true
                ? context.tr('addresses.required')
                : null
          : null,
    ),
  );
}

InputDecoration _decoration(BuildContext context, String labelKey) =>
    InputDecoration(
      labelText: context.tr(labelKey),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.onboardingPrimary),
      ),
    );
