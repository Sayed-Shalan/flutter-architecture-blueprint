import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/failure/app_failure.dart';
import '../../../core/result/result.dart';
import '../domain/booking.dart';
import 'booking_list_view_model.dart';

class CreateBookingState {
  const CreateBookingState({
    this.submitting = false,
    this.fieldErrors = const {},
    this.failure,
    this.created,
  });

  final bool submitting;
  final Map<BookingField, BookingFieldError> fieldErrors;
  final AppFailure? failure;
  final Booking? created;
}

class CreateBookingViewModel extends Notifier<CreateBookingState> {
  @override
  CreateBookingState build() => const CreateBookingState();

  /// Returns true when the booking was stored. Field errors stay on [state].
  Future<bool> submit(BookingDraft draft) async {
    state = const CreateBookingState(submitting: true);
    final result = await ref.read(bookingRepositoryProvider).create(draft);
    switch (result) {
      case Success(:final value):
        state = CreateBookingState(created: value);
        ref.invalidate(bookingListProvider);
        return true;
      case Err(failure: ValidationFailure(:final fields)):
        state = CreateBookingState(fieldErrors: fields);
        return false;
      case Err(:final failure):
        state = CreateBookingState(failure: failure);
        return false;
    }
  }
}

final createBookingProvider =
    NotifierProvider<CreateBookingViewModel, CreateBookingState>(
      CreateBookingViewModel.new,
    );
