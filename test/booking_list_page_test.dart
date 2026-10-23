import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_architecture_blueprint/app/booking_app.dart';
import 'package:flutter_architecture_blueprint/app/locale_controller.dart';
import 'package:flutter_architecture_blueprint/app/providers.dart';
import 'package:flutter_architecture_blueprint/app/router.dart';
import 'package:flutter_architecture_blueprint/core/failure/app_failure.dart';
import 'package:flutter_architecture_blueprint/core/result/result.dart';
import 'package:flutter_architecture_blueprint/features/bookings/data/demo_bookings.dart';
import 'package:flutter_architecture_blueprint/features/bookings/data/in_memory_booking_repository.dart';
import 'package:flutter_architecture_blueprint/features/bookings/domain/booking.dart';
import 'package:flutter_architecture_blueprint/features/bookings/domain/booking_repository.dart';
import 'package:flutter_architecture_blueprint/features/bookings/presentation/booking_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1, 9);

  Future<ProviderContainer> pump(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BookingApp(),
      ),
    );
    return container;
  }

  testWidgets('shows a loading indicator until the first page resolves', (
    tester,
  ) async {
    await pump(
      tester,
      ProviderContainer(
        overrides: [bookingListProvider.overrideWith(PendingListViewModel.new)],
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('booking-list-loading')), findsOneWidget);
  });

  testWidgets('shows the empty state', (tester) async {
    await pump(
      tester,
      ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWith(
            (ref) => InMemoryBookingRepository(now: () => now),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking-list-empty')), findsOneWidget);
  });

  testWidgets('shows the empty state in Arabic', (tester) async {
    await pump(
      tester,
      ProviderContainer(
        overrides: [
          localeProvider.overrideWith(ArabicLocale.new),
          bookingRepositoryProvider.overrideWith(
            (ref) => InMemoryBookingRepository(now: () => now),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا توجد حجوزات بعد'), findsOneWidget);
  });

  testWidgets('renders bookings and opens a deep link', (tester) async {
    final container = await pump(
      tester,
      ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWith(
            (ref) => InMemoryBookingRepository(
              now: () => now,
              seed: demoBookings(now),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking-tile-b1')), findsOneWidget);
    expect(find.text('Studio review'), findsOneWidget);

    container.read(routerProvider).go('/bookings/b1');
    await tester.pumpAndSettle();

    expect(find.text('Studio review'), findsOneWidget);
    expect(find.text('Noura Hassan'), findsOneWidget);
  });

  testWidgets('retry recovers from a failed load', (tester) async {
    final repository = _FlakyList(
      InMemoryBookingRepository(now: () => now, seed: demoBookings(now)),
    );
    await pump(
      tester,
      ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWith((ref) => repository),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking-list-error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('booking-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking-tile-b1')), findsOneWidget);
  });
}

class PendingListViewModel extends BookingListViewModel {
  @override
  Future<BookingListState> build() => Completer<BookingListState>().future;
}

class ArabicLocale extends LocaleController {
  @override
  Locale? build() => const Locale('ar');
}

class _FlakyList implements BookingRepository {
  _FlakyList(this._inner);

  final BookingRepository _inner;
  var _failed = false;

  @override
  Future<Result<Booking>> create(BookingDraft draft) => _inner.create(draft);

  @override
  Future<Result<Booking>> getById(String id) => _inner.getById(id);

  @override
  Future<Result<BookingPage>> list({
    required int page,
    int pageSize = 20,
  }) async {
    if (!_failed) {
      _failed = true;
      return const Err(NetworkFailure());
    }
    return _inner.list(page: page, pageSize: pageSize);
  }
}
