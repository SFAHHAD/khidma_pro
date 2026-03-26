import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/state.dart';

class ProviderJobScreen extends ConsumerStatefulWidget {
  const ProviderJobScreen({super.key, required this.booking});
  final Booking booking;

  @override
  ConsumerState<ProviderJobScreen> createState() => _ProviderJobScreenState();
}

class _ProviderJobScreenState extends ConsumerState<ProviderJobScreen> {
  late Booking _currentBooking;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  String? _getNextStatus() {
    switch (_currentBooking.status) {
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
        return 'Start Route (En Route)';
      case 'in_progress':
        return 'Arrived (Start Work)';
      case 'completed':
        return 'Mark as Completed';
      default:
        return '';
    }
  }

  Future<void> _updateStatus(String newStatus, {double? finalPrice}) async {
    final previousState = _currentBooking;
    setState(() {
      _isUpdating = true;
      _currentBooking = _currentBooking.copyWith(status: newStatus, finalPriceKwd: finalPrice);
    });

    try {
      final updated =
          await ref.read(apiClientProvider).updateBookingStatus(_currentBooking.id, newStatus, finalPrice: finalPrice);
      setState(() => _currentBooking = updated);

      ref.invalidate(availableBookingsProvider);
      ref.invalidate(myBookingsProvider);
    } catch (e) {
      setState(() => _currentBooking = previousState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed. Rolling back. (${e.toString()})'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _handleCompleteAction() async {
    final controller = TextEditingController(text: _currentBooking.priceEstimateKwd.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalize Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Confirm final price (KWD). Adjust if extra parts were needed.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Final Price (KWD)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Complete')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final price = double.tryParse(controller.text) ?? _currentBooking.priceEstimateKwd;
      _updateStatus('completed', finalPrice: price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('EEEE, MMM d @ h:mm a').format(_currentBooking.scheduledAt.toLocal());
    final nextStatus = _getNextStatus();

    return Scaffold(
      appBar: AppBar(title: Text('Job #${_currentBooking.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${_currentBooking.addressDetails}, ${_currentBooking.district}', style: const TextStyle(fontSize: 18)),
                  Text(_currentBooking.city, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text('SCHEDULED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_currentBooking.notes != null && _currentBooking.notes!.trim().isNotEmpty) ...[
            const Text('ISSUE NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(_currentBooking.notes!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
          ],
          const Text('FINANCIALS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('Estimate: ${_currentBooking.priceEstimateKwd.toStringAsFixed(2)} KWD', style: const TextStyle(fontSize: 16)),
          Text(
            'Final: ${_currentBooking.finalPriceKwd != null ? "${_currentBooking.finalPriceKwd!.toStringAsFixed(2)} KWD" : "Pending"}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      bottomNavigationBar: nextStatus != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _isUpdating
                        ? null
                        : () {
                            if (nextStatus == 'completed') {
                              _handleCompleteAction();
                            } else {
                              _updateStatus(nextStatus);
                            }
                          },
                    style: FilledButton.styleFrom(backgroundColor: nextStatus == 'completed' ? Colors.green : null),
                    child: _isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_getActionLabel(nextStatus), style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
