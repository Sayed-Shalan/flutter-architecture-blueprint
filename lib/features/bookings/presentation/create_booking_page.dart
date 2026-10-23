import 'package:flutter/material.dart';
import 'package:flutter_architecture_blueprint/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/failure/app_failure.dart';
import '../domain/booking.dart';
import 'create_booking_view_model.dart';
import 'failure_message.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  const CreateBookingPage({super.key});

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  final _title = TextEditingController();
  final _customer = TextEditingController();
  DateTime? _startAt;

  @override
  void dispose() {
    _title.dispose();
    _customer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(createBookingProvider);
    ref.listen(createBookingProvider, (previous, next) {
      final created = next.created;
      if (created != null && previous?.created?.id != created.id) {
        context.go('/bookings/${created.id}');
      }
    });
    final locale = Localizations.localeOf(context).toString();
    final startLabel = _startAt == null
        ? l10n.pickDate
        : DateFormat.yMMMd(locale).add_jm().format(_startAt!.toLocal());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBooking)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.titleLabel,
              errorText: _errorText(
                l10n,
                state.fieldErrors[BookingField.title],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customer,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.customerLabel,
              errorText: _errorText(
                l10n,
                state.fieldErrors[BookingField.customerName],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: state.submitting ? null : _pickStart,
            child: Text(startLabel),
          ),
          if (state.fieldErrors[BookingField.startAt] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                fieldErrorMessage(
                  l10n,
                  state.fieldErrors[BookingField.startAt]!,
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (state.failure != null) ...[
            const SizedBox(height: 16),
            Text(failureMessage(l10n, state.failure!)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.submitting ? null : _submit,
            child: Text(state.submitting ? l10n.saving : l10n.save),
          ),
        ],
      ),
    );
  }

  String? _errorText(AppLocalizations l10n, BookingFieldError? error) {
    if (error == null) {
      return null;
    }
    return fieldErrorMessage(l10n, error);
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _startAt ?? now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt ?? now),
    );
    if (time == null || !mounted) {
      return;
    }
    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() {
    return ref
        .read(createBookingProvider.notifier)
        .submit(
          BookingDraft(
            title: _title.text,
            customerName: _customer.text,
            startAt: _startAt,
          ),
        );
  }
}
