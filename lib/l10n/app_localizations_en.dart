// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bookings';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get emptyBookings => 'No bookings yet';

  @override
  String get retry => 'Retry';

  @override
  String get loadFailed => 'Could not load bookings';

  @override
  String get loadMore => 'Load more';

  @override
  String get loadMoreFailed => 'Could not load more bookings';

  @override
  String get createBooking => 'New booking';

  @override
  String get bookingDetails => 'Booking';

  @override
  String get titleLabel => 'Title';

  @override
  String get customerLabel => 'Customer';

  @override
  String get startLabel => 'Starts';

  @override
  String get pickDate => 'Choose a start time';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving';

  @override
  String get required => 'Required';

  @override
  String get mustBeFuture => 'Choose a future time';

  @override
  String get notFound => 'Booking not found';

  @override
  String get unexpectedError => 'Something went wrong';

  @override
  String get networkError => 'Network unavailable';

  @override
  String get timeoutError => 'The request timed out';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';
}
