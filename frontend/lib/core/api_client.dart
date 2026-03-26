import 'package:dio/dio.dart';

import 'models.dart';

class ApiClient {
  ApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            contentType: 'application/json',
          ),
        );

  final Dio _dio;
  String? _token;

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<String> login({required String email, required String password}) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final token = response.data['access_token'] as String;
    setToken(token);
    return token;
  }

  Future<List<ServiceItem>> fetchServices() async {
    final response = await _dio.get('/catalog/services');
    final data = response.data as List<dynamic>;
    return data.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Booking> createBooking({
    required int serviceId,
    required String district,
    required String addressDetails,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    if (_token == null) {
      throw StateError('You must be logged in before creating bookings.');
    }
    final response = await _dio.post(
      '/bookings',
      data: {
        'service_id': serviceId,
        'district': district,
        'address_details': addressDetails,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'notes': notes,
      },
    );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Booking>> myBookings() async {
    if (_token == null) {
      throw StateError('You must be logged in before viewing bookings.');
    }
    final response = await _dio.get('/bookings/me');
    final data = response.data as List<dynamic>;
    return data.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }
}
