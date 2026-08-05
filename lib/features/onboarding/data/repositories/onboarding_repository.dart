import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';

class OnboardingRepository {
  const OnboardingRepository();

  bool get isCompleted =>
      CacheHelper.getNullableBool(ConstantKeys.onboardingCompleted) ?? false;

  Future<void> complete() async {
    final saved = await CacheHelper.setData(
      ConstantKeys.onboardingCompleted,
      true,
    );
    if (saved != true) {
      throw StateError('Unable to save onboarding state.');
    }
  }
}
