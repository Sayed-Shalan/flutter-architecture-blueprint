/// Failures the UI can branch on without parsing exception text.
sealed class AppFailure implements Exception {
  const AppFailure();
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();
}

enum BookingField { title, customerName, startAt }

enum BookingFieldError { required, mustBeFuture }

final class ValidationFailure extends AppFailure {
  const ValidationFailure(this.fields);

  final Map<BookingField, BookingFieldError> fields;

  @override
  bool operator ==(Object other) {
    if (other is! ValidationFailure || other.fields.length != fields.length) {
      return false;
    }
    for (final entry in fields.entries) {
      if (other.fields[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
    fields.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}
