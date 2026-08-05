import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  void categorySelected(int index) =>
      emit(state.copyWith(selectedCategory: index));

  void navigationSelected(int index) =>
      emit(state.copyWith(selectedNavigationIndex: index));
}
