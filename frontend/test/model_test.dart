import 'package:flutter_test/flutter_test.dart';
import 'package:khidma_pro/core/models.dart';

void main() {
  group('ServiceItem.fromJson', () {
    test('parses service payload correctly', () {
      final service = ServiceItem.fromJson({
        'id': 1,
        'category_id': 3,
        'name_ar': 'إصلاح أعطال كهربائية',
        'name_en': 'Electrical Fault Fix',
        'base_price_kwd': 11,
      });

      expect(service.id, 1);
      expect(service.categoryId, 3);
      expect(service.nameAr, 'إصلاح أعطال كهربائية');
      expect(service.nameEn, 'Electrical Fault Fix');
      expect(service.basePriceKwd, 11.0);
    });
  });

  group('Booking.fromJson', () {
    test('parses booking payload and date correctly', () {
      final booking = Booking.fromJson({
        'id': 10,
        'service_id': 2,
        'city': 'Al Ahmadi',
        'district': 'Fahaheel',
        'address_details': 'Street 10',
        'status': 'pending',
        'price_estimate_kwd': 10.5,
        'scheduled_at': '2026-03-26T12:30:00Z',
      });

      expect(booking.id, 10);
      expect(booking.serviceId, 2);
      expect(booking.city, 'Al Ahmadi');
      expect(booking.district, 'Fahaheel');
      expect(booking.addressDetails, 'Street 10');
      expect(booking.statusRaw, 'pending');
      expect(booking.priceEstimateKwd, 10.5);
      expect(booking.scheduledAt.toUtc().toIso8601String(), '2026-03-26T12:30:00.000Z');
    });
  });
}
