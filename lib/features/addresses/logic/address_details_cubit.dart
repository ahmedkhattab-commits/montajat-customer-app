import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/addresses/data/models/address_model.dart';
import 'package:montajat_customer_app/features/addresses/data/repositories/addresses_repository.dart';

class AddressDetailsState {
  const AddressDetailsState({
    this.loading = false,
    this.saving = false,
    this.address,
    this.cities = const [],
    this.errorMessageKey,
  });
  final bool loading;
  final bool saving;
  final AddressModel? address;
  final List<CityModel> cities;
  final String? errorMessageKey;
}

class AddressDetailsCubit extends Cubit<AddressDetailsState> {
  AddressDetailsCubit(this._repository, this._id)
    : super(const AddressDetailsState());
  final AddressesRepository _repository;
  final int _id;

  Future<void> load() async {
    emit(const AddressDetailsState(loading: true));
    try {
      final results = await Future.wait([
        _repository.getAddress(_id),
        _repository.getCities(),
      ]);
      if (!isClosed) {
        emit(
          AddressDetailsState(
            address: results[0] as AddressModel,
            cities: results[1] as List<CityModel>,
          ),
        );
      }
    } on AddressesException catch (error) {
      if (!isClosed) {
        emit(AddressDetailsState(errorMessageKey: error.messageKey));
      }
    }
  }

  Future<bool> save(AddressModel address) async {
    emit(
      AddressDetailsState(
        saving: true,
        address: state.address,
        cities: state.cities,
      ),
    );
    try {
      final updated = await _repository.updateAddress(address);
      if (!isClosed) {
        emit(AddressDetailsState(address: updated, cities: state.cities));
      }
      return true;
    } on AddressesException catch (error) {
      if (!isClosed) {
        emit(
          AddressDetailsState(
            address: state.address,
            cities: state.cities,
            errorMessageKey: error.messageKey,
          ),
        );
      }
      return false;
    }
  }
}
