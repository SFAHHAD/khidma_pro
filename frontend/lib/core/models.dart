enum BookingStatus { pending, accepted, enRoute, inProgress, completed, cancelled }

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.basePriceKwd,
  });

  final int id;
  final int categoryId;
  final String nameAr;
  final String nameEn;
  final double basePriceKwd;

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        nameAr: json['name_ar'] as String,
        nameEn: json['name_en'] as String,
        basePriceKwd: (json['base_price_kwd'] as num).toDouble(),
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.serviceId,
    required this.city,
    required this.district,
    required this.addressDetails,
    required this.statusRaw,
    required this.priceEstimateKwd,
    required this.scheduledAt,
  });

  final int id;
  final int serviceId;
  final String city;
  final String district;
  final String addressDetails;
  final String statusRaw;
  final double priceEstimateKwd;
  final DateTime scheduledAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        serviceId: json['service_id'] as int,
        city: json['city'] as String,
        district: json['district'] as String,
        addressDetails: json['address_details'] as String,
        statusRaw: json['status'] as String,
        priceEstimateKwd: (json['price_estimate_kwd'] as num).toDouble(),
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      );
}
