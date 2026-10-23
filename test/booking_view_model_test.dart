import 'dart:async';

import 'package:flutter_architecture_blueprint/app/providers.dart';
import 'package:flutter_architecture_blueprint/core/failure/app_failure.dart';
import 'package:flutter_architecture_blueprint/core/result/result.dart';
import 'package:flutter_architecture_blueprint/features/bookings/data/in_memory_booking_repository.dart';
import 'package:flutter_architecture_blueprint/features/bookings/domain/booking.dart';
import 'package:flutter_architecture_blueprint/features/bookings/domain/booking_repository.dart';
import 'package:flutter_architecture_blueprint/features/bookings/presentation/booking_list_view_model.dart';
import 'package:flutter_architecture_blueprint/features/bookings/presentation/create_booking_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1, 9);

  Booking seed(int index) {
    return Booking(
      id: 'b$index',
      title: 'Booking $index',
      customerName: 'Customer $index',
      startAt: now.add(Duration(days: index + 1)),
      status: BookingStatus.scheduled,
    );
  }

  test('create stores a booking and the list reloads it', () async {
    final repository = InMemoryBookingRepository(now: () => now);
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    final created = await container
        .read(createBookingProvider.notifier)
        .submit(
          BookingDraft(
            title: 'Kickoff',
            customerName: 'Ada',
            startAt: now.add(const Duration(hours: 3)),
          ),
        );
    final page = await container.read(bookingListProvider.future);

    expect(created, isTrue);
    expect(page.items.single.title, 'Kickoff');
  });

  test('create keeps field errors and does not append a booking', () async {
    final repository = InMemoryBookingRepository(now: () => now);
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);

    final created = await container
        .read(createBookingProvider.notifier)
        .submit(
          BookingDraft(
            title: '',
            customerName: 'Ada',
            startAt: now.subtract(const Duration(minutes: 1)),
          ),
        );

    expect(created, isFalse);
    expect(container.read(createBookingProvider).fieldErrors, {
      BookingField.title: BookingFieldError.required,
      BookingField.startAt: BookingFieldError.mustBeFuture,
    });
    expect(
      (await repository.list(page: 1) as Success<BookingPage>).value.items,
      isEmpty,
    );
  });

  test('retry replaces a failed first page', () async {
    final inner = InMemoryBookingRepository(now: () => now, seed: [seed(0)]);
    final repository = _FlakyList(inner);
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWith((ref) => repository)],
    );
    final subscription = container.listen(bookingListProvider, (_, _) {});
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    await expectLater(
      container.read(bookingListProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    await container.read(bookingListProvider.notifier).retry();
    final page = container.read(bookingListProvider).requireValue;
    expect(page.items.single.id, 'b0');
  });

  test(
    'loadMore ignores a second call while the next page is in flight',
    () async {
      final inner = InMemoryBookingRepository(
        now: () => now,
        seed: [for (var i = 0; i < 25; i++) seed(i)],
      );
      final repository = _GatedPage(inner);
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final first = await container.read(bookingListProvider.future);
      expect(first.items, hasLength(20));
      expect(first.hasMore, isTrue);

      final firstMore = container.read(bookingListProvider.notifier).loadMore();
      final secondMore = container
          .read(bookingListProvider.notifier)
          .loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(repository.extraPageCalls, 1);

      repository.release();
      await Future.wait([firstMore, secondMore]);
      expect(
        container.read(bookingListProvider).requireValue.items,
        hasLength(25),
      );
    },
  );
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

class _GatedPage implements BookingRepository {
  _GatedPage(this._inner);

  final BookingRepository _inner;
  final Completer<void> _gate = Completer<void>();
  var extraPageCalls = 0;

  void release() {
    if (!_gate.isCompleted) {
      _gate.complete();
    }
  }

  @override
  Future<Result<Booking>> create(BookingDraft draft) => _inner.create(draft);

  @override
  Future<Result<Booking>> getById(String id) => _inner.getById(id);

  @override
  Future<Result<BookingPage>> list({
    required int page,
    int pageSize = 20,
  }) async {
    if (page > 1) {
      extraPageCalls += 1;
      await _gate.future;
    }
    return _inner.list(page: page, pageSize: pageSize);
  }
}
