import '../../../core/result/result.dart';
import 'booking.dart';

/// Page numbers start at 1. Implementations must not throw for expected
/// failures; they return [Err].
abstract interface class BookingRepository {
  Future<Result<BookingPage>> list({required int page, int pageSize = 20});

  Future<Result<Booking>> getById(String id);

  Future<Result<Booking>> create(BookingDraft draft);
}
