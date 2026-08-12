import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/addresses/data/models/address_model.dart';
import 'package:montajat_customer_app/features/addresses/data/repositories/addresses_repository.dart';

class AddressesState {
  const AddressesState({
    this.loading = false,
    this.addresses = const [],
    this.cities = const [],
    this.errorMessageKey,
  });
  final bool loading;
  final List<AddressModel> addresses;
  final List<CityModel> cities;
  final String? errorMessageKey;
}

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(this._repository) : super(const AddressesState());
  final AddressesRepository _repository;

  Future<void> loadAddresses() async {
    emit(const AddressesState(loading: true));
    try {
      final results = await Future.wait([
        _repository.getAddresses(),
        _repository.getCities(),
      ]);
      if (isClosed) return;
      emit(
        AddressesState(
          addresses: results[0] as List<AddressModel>,
          cities: results[1] as List<CityModel>,
        ),
      );
    } on AddressesException catch (error) {
      if (!isClosed) emit(AddressesState(errorMessageKey: error.messageKey));
    }
  }

  Future<void> setPreferred(int id) async {
    await _repository.setPreferred(id);
    await loadAddresses();
  }

  Future<AddressModel> update(AddressModel address) async {
    final updated = await _repository.updateAddress(address);
    await loadAddresses();
    return updated;
  }
}
