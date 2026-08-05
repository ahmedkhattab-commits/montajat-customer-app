import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Observer extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('Bloc error in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}
