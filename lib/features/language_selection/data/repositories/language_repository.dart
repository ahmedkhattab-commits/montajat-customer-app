import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';

class LanguageRepository {
  const LanguageRepository();

  String? getSavedLanguageCode() {
    return CacheHelper.getString(ConstantKeys.selectedLanguageCode);
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final saved = await CacheHelper.setData(
      ConstantKeys.selectedLanguageCode,
      languageCode,
    );
    if (saved != true) {
      throw StateError('Unable to save the selected language.');
    }
  }
}
