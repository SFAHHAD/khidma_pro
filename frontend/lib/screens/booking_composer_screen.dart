import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models.dart';
import '../core/state.dart';

class BookingComposerScreen extends ConsumerStatefulWidget {
  const BookingComposerScreen({super.key, required this.service});

  final ServiceItem service;

  @override
  ConsumerState<BookingComposerScreen> createState() => _BookingComposerScreenState();
}

class _BookingComposerScreenState extends ConsumerState<BookingComposerScreen> {
  static const _launchCities = ['Kuwait City', 'Al Ahmadi'];

  String _selectedCity = _launchCities.first;
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 2));
  bool _submitting = false;
  String? _result;

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
    if (_districtController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      setState(() => _result = 'District and address are required.');
      return;
    }
    setState(() {
      _submitting = true;
      _result = null;
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
      setState(() => _result = 'Booking #${booking.id} created successfully.');
    } catch (_) {
      setState(() => _result = 'Failed to create booking. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy-MM-dd HH:mm').format(_scheduledAt);
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service.nameEn}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Service: ${widget.service.nameAr}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Estimated price: ${widget.service.basePriceKwd.toStringAsFixed(2)} KWD'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(labelText: 'City'),
            items: _launchCities
                .map((city) => DropdownMenuItem<String>(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCity = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _districtController,
            decoration: const InputDecoration(labelText: 'District'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address details'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Issue notes (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Scheduled time'),
            subtitle: Text(formatted),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _pickDateTime,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting ? const CircularProgressIndicator() : const Text('Confirm Booking'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text(_result!),
          ],
        ],
      ),
    );
  }
}
