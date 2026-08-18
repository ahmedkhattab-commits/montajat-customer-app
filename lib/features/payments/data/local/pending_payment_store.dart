import 'package:montajat_customer_app/core/services/cache_helper.dart';

abstract interface class PendingPaymentStore {
  String? read(String orderNumber);

  Future<void> save(String orderNumber, String reference);

  Future<void> remove(String orderNumber);
}

class CachePendingPaymentStore implements PendingPaymentStore {
  const CachePendingPaymentStore();

  String _key(String orderNumber) => 'pending_payment_$orderNumber';

  @override
  String? read(String orderNumber) => CacheHelper.getString(_key(orderNumber));

  @override
  Future<void> save(String orderNumber, String reference) async {
    await CacheHelper.setData(_key(orderNumber), reference);
  }

  @override
  Future<void> remove(String orderNumber) async {
    await CacheHelper.removeData(_key(orderNumber));
  }
}
