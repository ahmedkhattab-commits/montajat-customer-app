import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/reorder/data/models/reorder_product_model.dart';
import 'package:montajat_customer_app/features/reorder/data/repositories/reorder_repository.dart';

class ReorderState {
  const ReorderState({
    this.loading = false,
    this.myProducts = const [],
    this.dueProducts = const [],
    this.error,
  });
  final bool loading;
  final List<ReorderProductModel> myProducts;
  final List<ReorderProductModel> dueProducts;
  final String? error;
}

class ReorderCubit extends Cubit<ReorderState> {
  ReorderCubit(this._repository) : super(const ReorderState());
  final ReorderRepository _repository;

  Future<void> load() async {
    emit(
      ReorderState(
        loading: true,
        myProducts: state.myProducts,
        dueProducts: state.dueProducts,
      ),
    );
    try {
      final results = await Future.wait([
        _repository.getMyProducts(),
        _repository.getDueProducts(),
      ]);
      if (!isClosed) {
        emit(ReorderState(myProducts: results[0], dueProducts: results[1]));
      }
    } on ReorderException catch (error) {
      if (!isClosed) {
        emit(
          ReorderState(
            myProducts: state.myProducts,
            dueProducts: state.dueProducts,
            error: error.messageKey,
          ),
        );
      }
    }
  }
}
