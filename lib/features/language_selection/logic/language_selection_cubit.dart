import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/language_selection/data/repositories/language_repository.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_state.dart';

class LanguageSelectionCubit extends Cubit<LanguageSelectionState> {
  LanguageSelectionCubit(this._repository)
    : super(
        LanguageSelectionInitial(
          selectedLanguageCode: _repository.getSavedLanguageCode(),
        ),
      );

  final LanguageRepository _repository;

  Future<void> selectLanguage(String languageCode) async {
    if (state is LanguageSelectionSaving) return;

    emit(LanguageSelectionSaving(selectedLanguageCode: languageCode));
    try {
      await _repository.saveLanguageCode(languageCode);
      if (!isClosed) {
        emit(LanguageSelectionSaved(selectedLanguageCode: languageCode));
      }
    } on Object {
      if (!isClosed) {
        emit(
          LanguageSelectionFailure(
            selectedLanguageCode: state.selectedLanguageCode,
            messageKey: 'language_selection.save_error',
          ),
        );
      }
    }
  }
}
