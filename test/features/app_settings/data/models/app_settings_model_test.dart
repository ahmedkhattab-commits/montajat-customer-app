import 'package:flutter_test/flutter_test.dart';
import 'package:montajat_customer_app/features/app_settings/data/models/app_settings_model.dart';

void main() {
  test('does not block when orders are accepted while the store is closed', () {
    final settings = AppSettingsModel.fromJson(const {
      'is_open': false,
      'accepts_orders_when_closed': true,
      'maintenance': {'active': false},
      'version': {'force_update': false},
    });

    expect(settings.blocksApp, isFalse);
  });

  test('blocks and reads the maintenance image when maintenance is active', () {
    final settings = AppSettingsModel.fromJson(const {
      'is_open': true,
      'maintenance': {
        'active': true,
        'message': 'Maintenance',
        'image_url': 'https://example.com/maintenance.png',
      },
      'version': {'force_update': false},
    });

    expect(settings.blocksApp, isTrue);
    expect(settings.message, 'Maintenance');
    expect(settings.imageUrl, 'https://example.com/maintenance.png');
  });

  test('blocks when the minimum app version is forced', () {
    final settings = AppSettingsModel.fromJson(const {
      'is_open': true,
      'maintenance': {'active': false},
      'version': {'force_update': true},
    });

    expect(settings.blocksApp, isTrue);
  });
}
