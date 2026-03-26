class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.basePriceKwd,
    required this.pricingType,
    required this.durationEstimateMin,
  });

  final int id;
  final int categoryId;
  final String nameAr;
  final String nameEn;
  final double basePriceKwd;
  final String pricingType;
  final int durationEstimateMin;

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        nameAr: json['name_ar'] as String,
        nameEn: json['name_en'] as String,
        basePriceKwd: (json['base_price_kwd'] as num).toDouble(),
        pricingType: json['pricing_type'] as String? ?? 'fixed',
        durationEstimateMin: json['duration_estimate_min'] as int? ?? 60,
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.city,
    required this.district,
    required this.addressDetails,
    required this.scheduledAt,
    required this.status,
    required this.notes,
    required this.priceEstimateKwd,
    required this.finalPriceKwd,
    required this.createdAt,
  });

  final int id;
  final int customerId;
  final int? providerId;
  final int serviceId;
  final String city;
  final String district;
  final String addressDetails;
  final DateTime scheduledAt;
  final String status;
  final String? notes;
  final double priceEstimateKwd;
  final double? finalPriceKwd;
  final DateTime createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        customerId: json['customer_id'] as int,
        providerId: json['provider_id'] as int?,
        serviceId: json['service_id'] as int,
        city: json['city'] as String,
        district: json['district'] as String,
        addressDetails: json['address_details'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        status: json['status'] as String,
        notes: json['notes'] as String?,
        priceEstimateKwd: (json['price_estimate_kwd'] as num).toDouble(),
        finalPriceKwd: (json['final_price_kwd'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Booking copyWith({
    String? status,
    double? finalPriceKwd,
  }) {
    return Booking(
      id: id,
      customerId: customerId,
      providerId: providerId,
      serviceId: serviceId,
      city: city,
      district: district,
      addressDetails: addressDetails,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      notes: notes,
      priceEstimateKwd: priceEstimateKwd,
      finalPriceKwd: finalPriceKwd ?? this.finalPriceKwd,
      createdAt: createdAt,
    );
  }
}
