import 'package:flutter/material.dart';
import 'package:flutter_architecture_blueprint/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/locale_controller.dart';
import '../../../core/failure/app_failure.dart';
import '../domain/booking.dart';
import 'booking_list_view_model.dart';
import 'failure_message.dart';

class BookingListPage extends ConsumerWidget {
  const BookingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bookings = ref.watch(bookingListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingsTitle),
        actions: const [_LanguageMenu()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bookings/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.createBooking),
      ),
      body: bookings.when(
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('booking-list-loading')),
        ),
        error: (error, _) => _ListError(
          message: error is AppFailure
              ? failureMessage(l10n, error)
              : l10n.loadFailed,
          onRetry: () => ref.read(bookingListProvider.notifier).retry(),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(bookingListProvider.notifier).refresh(),
              child: ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      l10n.emptyBookings,
                      key: const Key('booking-list-empty'),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(bookingListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: state.items.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return _ListFooter(state: state);
                }
                final booking = state.items[index];
                return _BookingTile(booking: booking);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<AppLanguage>(
      tooltip: l10n.language,
      onSelected: ref.read(localeProvider.notifier).use,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppLanguage.system,
          child: Text(l10n.languageSystem),
        ),
        PopupMenuItem(
          value: AppLanguage.english,
          child: Text(l10n.languageEnglish),
        ),
        PopupMenuItem(
          value: AppLanguage.arabic,
          child: Text(l10n.languageArabic),
        ),
      ],
      icon: const Icon(Icons.language),
    );
  }
}

class _ListError extends StatelessWidget {
  const _ListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      key: const Key('booking-list-error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('booking-retry'),
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListFooter extends ConsumerWidget {
  const _ListFooter({required this.state});

  final BookingListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        if (state.loadMoreFailure != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.loadMoreFailed, textAlign: TextAlign.center),
          ),
        if (state.hasMore || state.loadMoreFailure != null)
          TextButton(
            key: const Key('booking-load-more'),
            onPressed: () => ref.read(bookingListProvider.notifier).loadMore(),
            child: Text(l10n.loadMore),
          ),
      ],
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final when = DateFormat.yMMMd(
      locale,
    ).add_jm().format(booking.startAt.toLocal());
    return Card(
      key: Key('booking-tile-${booking.id}'),
      child: ListTile(
        title: Text(booking.title),
        subtitle: Text('${booking.customerName}\n$when'),
        isThreeLine: true,
        trailing: Text(statusLabel(l10n, booking.status)),
        onTap: () => context.push('/bookings/${booking.id}'),
      ),
    );
  }
}
