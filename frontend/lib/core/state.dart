import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = switch (defaultTargetPlatform) {
    // Android emulator maps host machine localhost to 10.0.2.2
    TargetPlatform.android => 'http://10.0.2.2:8001',
    _ => 'http://127.0.0.1:8001',
  };
  return ApiClient(baseUrl: baseUrl);
});

final authTokenProvider = StateProvider<String?>((ref) => null);

final servicesProvider = FutureProvider<List<ServiceItem>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchServices();
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.myBookings();
});
