import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/state.dart';
import '../core/theme.dart';
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
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.fullName ?? 'Provider',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                _isOnline ? 'You are online' : 'You are offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _isOnline ? const Color(0xFF2E7D32) : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          toolbarHeight: 64,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOnline ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    onChanged: (val) => setState(() => _isOnline = val),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text('Requests'),
                    if (_isOnline) ...[
                      const SizedBox(width: 6),
                      _TabDot(color: scheme.primary),
                    ],
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('My Schedule'),
                  ],
                ),
              ),
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

class _TabDot extends StatelessWidget {
  const _TabDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AvailableRequestsTab extends ConsumerWidget {
  const _AvailableRequestsTab({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOnline) {
      return const EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'You\'re offline',
        subtitle: 'Switch online to receive new job requests.',
      );
    }

    final availableAsync = ref.watch(availableBookingsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(availableBookingsProvider.future),
      child: availableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.refresh(availableBookingsProvider),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'All caught up',
              subtitle: 'No new requests right now. Pull to refresh.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _JobCard(booking: bookings[index], isAvailable: true),
            ),
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
        error: (err, _) => ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.refresh(myBookingsProvider),
        ),
        data: (bookings) {
          final active =
              bookings.where((b) => b.status != 'completed' && b.status != 'cancelled').toList();
          if (active.isEmpty) {
            return const EmptyState(
              icon: Icons.event_available_rounded,
              title: 'Schedule is clear',
              subtitle: 'Accepted jobs will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _JobCard(booking: active[index], isAvailable: false),
            ),
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
    final time = DateFormat('h:mm a').format(booking.scheduledAt.toLocal());
    final date = DateFormat('EEE, MMM d').format(booking.scheduledAt.toLocal());

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProviderJobScreen(booking: booking)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${booking.district}, ${booking.city}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  if (!isAvailable) StatusBadge(booking.status, small: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '$date at $time',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.priceEstimateKwd.toStringAsFixed(2)} KWD estimate',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (isAvailable) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProviderJobScreen(booking: booking)),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('View request'),
                    style: FilledButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
