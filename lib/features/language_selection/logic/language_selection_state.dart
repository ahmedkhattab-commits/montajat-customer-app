sealed class LanguageSelectionState {
  const LanguageSelectionState({this.selectedLanguageCode});

  final String? selectedLanguageCode;
}

final class LanguageSelectionInitial extends LanguageSelectionState {
  const LanguageSelectionInitial({super.selectedLanguageCode});
}

final class LanguageSelectionSaving extends LanguageSelectionState {
  const LanguageSelectionSaving({required super.selectedLanguageCode});
}

final class LanguageSelectionSaved extends LanguageSelectionState {
  const LanguageSelectionSaved({required super.selectedLanguageCode});
}

final class LanguageSelectionFailure extends LanguageSelectionState {
  const LanguageSelectionFailure({
    required super.selectedLanguageCode,
    required this.messageKey,
  });

  final String messageKey;
}
