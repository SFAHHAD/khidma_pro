import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/state.dart';

class BookingTrackerScreen extends ConsumerWidget {
  const BookingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load bookings: $error')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final date = DateFormat('yyyy-MM-dd HH:mm').format(booking.scheduledAt.toLocal());
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking #${booking.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Status: ${booking.statusRaw}'),
                      Text('Location: ${booking.city}, ${booking.district}'),
                      Text('Address: ${booking.addressDetails}'),
                      Text('Scheduled: $date'),
                      Text('Estimate: ${booking.priceEstimateKwd.toStringAsFixed(2)} KWD'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
