import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/state.dart';
import '../core/theme.dart';

class BookingComposerScreen extends ConsumerStatefulWidget {
  const BookingComposerScreen({super.key, required this.service});
  final ServiceItem service;

  @override
  ConsumerState<BookingComposerScreen> createState() => _BookingComposerScreenState();
}

class _BookingComposerScreenState extends ConsumerState<BookingComposerScreen> {
  static const _launchCities = ['Kuwait City', 'Al Ahmadi'];

  final _formKey = GlobalKey<FormState>();
  String _selectedCity = _launchCities.first;
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 2));
  bool _submitting = false;
  bool _success = false;
  int? _createdBookingId;

  @override
  void dispose() {
    _districtController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: _scheduledAt,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
    });
    try {
      final api = ref.read(apiClientProvider);
      final booking = await api.createBooking(
        serviceId: widget.service.id,
        city: _selectedCity,
        district: _districtController.text.trim(),
        addressDetails: _addressController.text.trim(),
        scheduledAt: _scheduledAt,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      ref.invalidate(myBookingsProvider);
      setState(() {
        _success = true;
        _createdBookingId = booking.id;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Confirmed')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 44),
                ),
                const SizedBox(height: 24),
                Text(
                  'Booking #$_createdBookingId confirmed',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll match you with a provider shortly.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Services'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final formatted = DateFormat('EEE, MMM d • h:mm a').format(_scheduledAt);

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service.nameEn}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Service summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(ServiceIcon.forName(widget.service.nameEn), color: scheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.service.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(widget.service.nameAr,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.service.basePriceKwd.toStringAsFixed(2)} KWD',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const _SectionHeader(label: 'Location'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              items: _launchCities
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCity = v);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _districtController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'District',
                hintText: 'e.g. Salmiya, Rumaithiya',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'District is required';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Street address & building',
                hintText: 'Block, street, building number',
                prefixIcon: Icon(Icons.home_outlined),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Address is required';
                if (v.trim().length < 6) return 'Please provide a more complete address';
                return null;
              },
            ),
            const SizedBox(height: 24),

            const _SectionHeader(label: 'Scheduling'),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preferred date & time',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          const SizedBox(height: 2),
                          Text(formatted,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_calendar_rounded, color: scheme.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const _SectionHeader(label: 'Additional notes (optional)'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Describe the issue',
                hintText: 'e.g. AC not cooling, strange noise from unit',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Confirm Booking'),
            ),
            const SizedBox(height: 12),
            Text(
              'A provider will confirm shortly. You can track status in My Bookings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}
