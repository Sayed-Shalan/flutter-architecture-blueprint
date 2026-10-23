import 'package:flutter/material.dart';
import 'package:flutter_architecture_blueprint/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/failure/app_failure.dart';
import 'booking_detail_view_model.dart';
import 'failure_message.dart';

class BookingDetailPage extends ConsumerWidget {
  const BookingDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(bookingDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetails)),
      body: booking.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is AppFailure
                      ? failureMessage(l10n, error)
                      : l10n.unexpectedError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(bookingDetailProvider(id).notifier).retry(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (value) {
          final locale = Localizations.localeOf(context).toString();
          final when = DateFormat.yMMMd(
            locale,
          ).add_jm().format(value.startAt.toLocal());
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                value.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(value.customerName),
              const SizedBox(height: 8),
              Text(when),
              const SizedBox(height: 8),
              Text(statusLabel(l10n, value.status)),
            ],
          );
        },
      ),
    );
  }
}
