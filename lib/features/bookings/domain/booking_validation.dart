import '../../../core/failure/app_failure.dart';
import 'booking.dart';

ValidationFailure? validateBookingDraft(
  BookingDraft draft, {
  required DateTime now,
}) {
  final fields = <BookingField, BookingFieldError>{};
  if (draft.title.trim().isEmpty) {
    fields[BookingField.title] = BookingFieldError.required;
  }
  if (draft.customerName.trim().isEmpty) {
    fields[BookingField.customerName] = BookingFieldError.required;
  }
  final startAt = draft.startAt;
  if (startAt == null) {
    fields[BookingField.startAt] = BookingFieldError.required;
  } else if (!startAt.isAfter(now)) {
    fields[BookingField.startAt] = BookingFieldError.mustBeFuture;
  }
  if (fields.isEmpty) {
    return null;
  }
  return ValidationFailure(fields);
}
