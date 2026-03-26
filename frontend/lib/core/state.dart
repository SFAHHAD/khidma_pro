import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  // Keep Android emulator routing stable while supporting local web/desktop.
  final baseUrl = kIsWeb
      ? 'http://127.0.0.1:8001'
      : switch (defaultTargetPlatform) {
          TargetPlatform.android => 'http://10.0.2.2:8001',
          _ => 'http://127.0.0.1:8001',
        };
  return ApiClient(baseUrl: baseUrl);
});

final authTokenProvider = StateProvider<String?>((ref) => null);
final currentUserProvider = StateProvider<UserProfile?>((ref) => null);

final servicesProvider = FutureProvider<List<ServiceItem>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchServices();
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.myBookings();
});

final availableBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchAvailableBookings();
});
