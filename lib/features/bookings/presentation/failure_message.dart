import 'package:flutter_architecture_blueprint/l10n/app_localizations.dart';

import '../../../core/failure/app_failure.dart';
import '../domain/booking.dart';

String failureMessage(AppLocalizations l10n, AppFailure failure) {
  return switch (failure) {
    NetworkFailure() => l10n.networkError,
    TimeoutFailure() => l10n.timeoutError,
    NotFoundFailure() => l10n.notFound,
    ValidationFailure() => l10n.unexpectedError,
    UnexpectedFailure() => l10n.unexpectedError,
  };
}

String fieldErrorMessage(AppLocalizations l10n, BookingFieldError error) {
  return switch (error) {
    BookingFieldError.required => l10n.required,
    BookingFieldError.mustBeFuture => l10n.mustBeFuture,
  };
}

String statusLabel(AppLocalizations l10n, BookingStatus status) {
  return switch (status) {
    BookingStatus.scheduled => l10n.statusScheduled,
    BookingStatus.completed => l10n.statusCompleted,
    BookingStatus.cancelled => l10n.statusCancelled,
  };
}
