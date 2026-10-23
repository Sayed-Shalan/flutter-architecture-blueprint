import 'package:flutter_architecture_blueprint/core/failure/app_failure.dart';
import 'package:flutter_architecture_blueprint/core/result/result.dart';
import 'package:flutter_architecture_blueprint/features/bookings/data/in_memory_booking_repository.dart';
import 'package:flutter_architecture_blueprint/features/bookings/domain/booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1, 9);

  Booking booking(String id, int day) {
    return Booking(
      id: id,
      title: 'Booking $id',
      customerName: 'Customer $id',
      startAt: DateTime.utc(2026, 6, day, 10),
      status: BookingStatus.scheduled,
    );
  }

  test(
    'returns a page and the following page without duplicating items',
    () async {
      final repository = InMemoryBookingRepository(
        now: () => now,
        seed: [booking('b', 3), booking('a', 1), booking('c', 2)],
      );

      final first = await repository.list(page: 1, pageSize: 2);
      final second = await repository.list(page: 2, pageSize: 2);

      expect(first, isA<Success<BookingPage>>());
      final firstPage = (first as Success<BookingPage>).value;
      expect(firstPage.items.map((item) => item.id), ['a', 'c']);
      expect(firstPage.totalCount, 3);
      expect(firstPage.hasMore, isTrue);

      final secondPage = (second as Success<BookingPage>).value;
      expect(secondPage.items.map((item) => item.id), ['b']);
      expect(secondPage.hasMore, isFalse);
    },
  );

  test(
    'rejects an empty title and a start time that is not in the future',
    () async {
      final repository = InMemoryBookingRepository(now: () => now);

      final missing = await repository.create(
        const BookingDraft(title: '  ', customerName: 'Ada', startAt: null),
      );
      final past = await repository.create(
        BookingDraft(
          title: 'Kickoff',
          customerName: 'Ada',
          startAt: now.subtract(const Duration(minutes: 1)),
        ),
      );

      expect(
        (missing as Err<Booking>).failure,
        const ValidationFailure({
          BookingField.title: BookingFieldError.required,
          BookingField.startAt: BookingFieldError.required,
        }),
      );
      expect(
        (past as Err<Booking>).failure,
        const ValidationFailure({
          BookingField.startAt: BookingFieldError.mustBeFuture,
        }),
      );
      final listed = await repository.list(page: 1);
      expect((listed as Success<BookingPage>).value.totalCount, 0);
    },
  );

  test('create then getById returns the stored booking', () async {
    final repository = InMemoryBookingRepository(
      now: () => now,
      idFactory: () => 'local-1',
    );
    final start = now.add(const Duration(days: 1));

    final created = await repository.create(
      BookingDraft(title: ' Kickoff ', customerName: ' Ada ', startAt: start),
    );
    final loaded = await repository.getById('local-1');
    final missing = await repository.getById('missing');

    final booking = (created as Success<Booking>).value;
    expect(booking.title, 'Kickoff');
    expect(booking.customerName, 'Ada');
    expect((loaded as Success<Booking>).value, booking);
    expect((missing as Err<Booking>).failure, isA<NotFoundFailure>());
  });

  test('rejects a page number below 1', () async {
    final repository = InMemoryBookingRepository(now: () => now);
    final result = await repository.list(page: 0);
    expect((result as Err<BookingPage>).failure, isA<UnexpectedFailure>());
  });
}
