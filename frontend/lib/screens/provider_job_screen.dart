import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/state.dart';
import '../core/theme.dart';

class ProviderJobScreen extends ConsumerStatefulWidget {
  const ProviderJobScreen({super.key, required this.booking});
  final Booking booking;

  @override
  ConsumerState<ProviderJobScreen> createState() => _ProviderJobScreenState();
}

class _ProviderJobScreenState extends ConsumerState<ProviderJobScreen> {
  late Booking _booking;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  String? _getNextStatus() {
    switch (_booking.status) {
      case 'pending':
        return 'accepted';
      case 'accepted':
        return 'en_route';
      case 'en_route':
        return 'in_progress';
      case 'in_progress':
        return 'completed';
      default:
        return null;
    }
  }

  String _getActionLabel(String nextStatus) {
    switch (nextStatus) {
      case 'accepted':
        return 'Accept Job';
      case 'en_route':
        return 'I\'m on the way';
      case 'in_progress':
        return 'I\'ve arrived — Start Work';
      case 'completed':
        return 'Mark Job as Complete';
      default:
        return '';
    }
  }

  IconData _getActionIcon(String nextStatus) {
    switch (nextStatus) {
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'en_route':
        return Icons.directions_car_rounded;
      case 'in_progress':
        return Icons.build_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  Future<void> _updateStatus(String newStatus, {double? finalPrice}) async {
    final previous = _booking;
    setState(() {
      _isUpdating = true;
      _booking = _booking.copyWith(status: newStatus, finalPriceKwd: finalPrice);
    });

    try {
      final updated = await ref
          .read(apiClientProvider)
          .updateBookingStatus(_booking.id, newStatus, finalPrice: finalPrice);
      setState(() => _booking = updated);
      ref.invalidate(availableBookingsProvider);
      ref.invalidate(myBookingsProvider);
    } catch (e) {
      setState(() => _booking = previous);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _handleCompleteAction() async {
    final controller = TextEditingController(text: _booking.priceEstimateKwd.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalize Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm the final price in KWD. Adjust if extra parts were needed.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Final Price (KWD)',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Complete Job')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final price = double.tryParse(controller.text) ?? _booking.priceEstimateKwd;
      _updateStatus('completed', finalPrice: price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = DateFormat('EEEE, MMM d').format(_booking.scheduledAt.toLocal());
    final timeOnly = DateFormat('h:mm a').format(_booking.scheduledAt.toLocal());
    final nextStatus = _getNextStatus();
    final isCompleted = _booking.status == 'completed';
    final isCancelled = _booking.status == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: Text('Job #${_booking.id}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusBadge(_booking.status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Location card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('LOCATION'),
                  const SizedBox(height: 8),
                  Text(
                    '${_booking.addressDetails}, ${_booking.district}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(_booking.city, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  const SectionLabel('SCHEDULED'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded, size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(timeOnly, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notes card (if present)
          if (_booking.notes != null && _booking.notes!.trim().isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('CUSTOMER NOTES'),
                    const SizedBox(height: 8),
                    Text(_booking.notes!, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Financials card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('PRICING'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FinanceItem(
                        label: 'Estimate',
                        value: '${_booking.priceEstimateKwd.toStringAsFixed(2)} KWD',
                      ),
                      if (_booking.finalPriceKwd != null) ...[
                        const SizedBox(width: 16),
                        _FinanceItem(
                          label: 'Final',
                          value: '${_booking.finalPriceKwd!.toStringAsFixed(2)} KWD',
                          primary: true,
                        ),
                      ] else ...[
                        const SizedBox(width: 16),
                        const _FinanceItem(label: 'Final', value: 'Pending'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Completed state message
          if (isCompleted) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.task_alt_rounded, color: Color(0xFF2E7D32), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Job completed successfully.',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isCancelled) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.grey.shade500, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'This booking was cancelled.',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: nextStatus != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: FilledButton.icon(
                  onPressed: _isUpdating
                      ? null
                      : () {
                          if (nextStatus == 'completed') {
                            _handleCompleteAction();
                          } else {
                            _updateStatus(nextStatus);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: nextStatus == 'completed' ? const Color(0xFF2E7D32) : scheme.primary,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Icon(_getActionIcon(nextStatus)),
                  label: _isUpdating
                      ? const Text('Updating…')
                      : Text(_getActionLabel(nextStatus)),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _FinanceItem extends StatelessWidget {
  const _FinanceItem({required this.label, required this.value, this.primary = false});
  final String label;
  final String value;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primary ? scheme.primary : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
