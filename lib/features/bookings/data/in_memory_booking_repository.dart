import '../../../core/failure/app_failure.dart';
import '../../../core/result/result.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_validation.dart';

class InMemoryBookingRepository implements BookingRepository {
  InMemoryBookingRepository({
    required DateTime Function() now,
    List<Booking> seed = const [],
    String Function()? idFactory,
  }) : _now = now,
       _items = [...seed],
       _idFactory = idFactory ?? _defaultIds();

  final DateTime Function() _now;
  final List<Booking> _items;
  final String Function() _idFactory;

  static String Function() _defaultIds() {
    var next = 1;
    return () => 'local-${next++}';
  }

  @override
  Future<Result<Booking>> create(BookingDraft draft) async {
    final validation = validateBookingDraft(draft, now: _now());
    if (validation != null) {
      return Err(validation);
    }
    final booking = Booking(
      id: _idFactory(),
      title: draft.title.trim(),
      customerName: draft.customerName.trim(),
      startAt: draft.startAt!.toUtc(),
      status: BookingStatus.scheduled,
    );
    _items.add(booking);
    return Success(booking);
  }

  @override
  Future<Result<Booking>> getById(String id) async {
    for (final booking in _items) {
      if (booking.id == id) {
        return Success(booking);
      }
    }
    return const Err(NotFoundFailure());
  }

  @override
  Future<Result<BookingPage>> list({
    required int page,
    int pageSize = 20,
  }) async {
    if (page < 1 || pageSize < 1) {
      return const Err(UnexpectedFailure());
    }
    final sorted = [..._items]..sort((a, b) => a.startAt.compareTo(b.startAt));
    final start = (page - 1) * pageSize;
    final items = start >= sorted.length
        ? const <Booking>[]
        : sorted.skip(start).take(pageSize).toList(growable: false);
    return Success(
      BookingPage(
        items: items,
        page: page,
        pageSize: pageSize,
        totalCount: sorted.length,
      ),
    );
  }
}
