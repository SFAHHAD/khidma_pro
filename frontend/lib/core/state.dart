import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  // Replace with your local or deployed API URL.
  return ApiClient(baseUrl: 'http://127.0.0.1:8000');
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
