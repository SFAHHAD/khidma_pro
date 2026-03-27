import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/state.dart';
import '../core/theme.dart';

class BookingTrackerScreen extends ConsumerWidget {
  const BookingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.refresh(myBookingsProvider),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No bookings yet',
              subtitle: 'Once you book a service, it will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myBookingsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final scheduledDate = DateFormat('EEE, MMM d').format(booking.scheduledAt.toLocal());
                final scheduledTime = DateFormat('h:mm a').format(booking.scheduledAt.toLocal());

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              Text(
                                'Booking #${booking.id}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const Spacer(),
                              StatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            text: '${booking.district}, ${booking.city}',
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.home_rounded,
                            text: booking.addressDetails,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            text: '$scheduledDate at $scheduledTime',
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _PriceChip(
                                label: 'Estimate',
                                value: '${booking.priceEstimateKwd.toStringAsFixed(2)} KWD',
                              ),
                              if (booking.finalPriceKwd != null) ...[
                                const SizedBox(width: 8),
                                _PriceChip(
                                  label: 'Final',
                                  value: '${booking.finalPriceKwd!.toStringAsFixed(2)} KWD',
                                  highlight: true,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? scheme.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: highlight ? scheme.primary : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
