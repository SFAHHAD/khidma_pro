import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/state.dart';
import 'provider_job_screen.dart';

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  ConsumerState<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends ConsumerState<ProviderDashboardScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dispatch: ${profile?.fullName ?? "Provider"}', style: const TextStyle(fontSize: 18)),
            ],
          ),
          actions: [
            Row(
              children: [
                Text(_isOnline ? 'Online' : 'Offline', style: const TextStyle(fontSize: 14)),
                Switch(
                  value: _isOnline,
                  onChanged: (val) => setState(() => _isOnline = val),
                  activeThumbColor: Colors.greenAccent,
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available Requests'),
              Tab(text: 'My Schedule'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AvailableRequestsTab(isOnline: _isOnline),
            const _MyScheduleTab(),
          ],
        ),
      ),
    );
  }
}

class _AvailableRequestsTab extends ConsumerWidget {
  const _AvailableRequestsTab({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOnline) {
      return const Center(child: Text('Go online to see new requests.', style: TextStyle(fontSize: 16)));
    }

    final availableAsync = ref.watch(availableBookingsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(availableBookingsProvider.future),
      child: availableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (bookings) {
          if (bookings.isEmpty) return const Center(child: Text('No new requests available.'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return _JobCard(booking: b, isAvailable: true);
            },
          );
        },
      ),
    );
  }
}

class _MyScheduleTab extends ConsumerWidget {
  const _MyScheduleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myJobsAsync = ref.watch(myBookingsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myBookingsProvider.future),
      child: myJobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (bookings) {
          final activeJobs =
              bookings.where((b) => b.status != 'completed' && b.status != 'cancelled').toList();
          if (activeJobs.isEmpty) return const Center(child: Text('Your schedule is clear.'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: activeJobs.length,
            itemBuilder: (context, index) {
              return _JobCard(booking: activeJobs[index], isAvailable: false);
            },
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.booking, required this.isAvailable});
  final Booking booking;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a, MMM d').format(booking.scheduledAt.toLocal());
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('${booking.district}, ${booking.city}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('Scheduled: $time'),
            Text('Est: ${booking.priceEstimateKwd.toStringAsFixed(2)} KWD'),
            if (!isAvailable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(booking.status.toUpperCase(), style: TextStyle(color: Colors.blue.shade900, fontSize: 12)),
              )
            ]
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProviderJobScreen(booking: booking)),
          );
        },
      ),
    );
  }
}
