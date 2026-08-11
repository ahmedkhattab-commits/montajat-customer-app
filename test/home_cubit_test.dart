import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';

void main() {
  test('does not emit when the response arrives after close', () async {
    final repository = _DelayedHomeRepository();
    final cubit = HomeCubit(repository);

    final loadFuture = cubit.loadHome();
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    repository.complete(const HomeResponseModel(sections: []));

    await expectLater(loadFuture, completes);
  });
}

class _DelayedHomeRepository implements HomeRepository {
  final _completer = Completer<HomeResponseModel>();

  @override
  Future<HomeResponseModel> getHome() => _completer.future;

  void complete(HomeResponseModel response) => _completer.complete(response);
}
