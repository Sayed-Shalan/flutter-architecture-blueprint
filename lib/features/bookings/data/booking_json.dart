import '../../../core/failure/app_failure.dart';
import '../../../core/result/result.dart';
import '../domain/booking.dart';

Result<Booking> parseBooking(Object? json) {
  if (json is! Map) {
    return const Err(UnexpectedFailure());
  }
  final id = json['id'];
  final title = json['title'];
  final customerName = json['customerName'];
  final startRaw = json['startAt'];
  final statusRaw = json['status'];
  if (id is! String ||
      title is! String ||
      customerName is! String ||
      startRaw is! String ||
      statusRaw is! String) {
    return const Err(UnexpectedFailure());
  }
  final DateTime startAt;
  try {
    startAt = DateTime.parse(startRaw).toUtc();
  } on FormatException {
    return const Err(UnexpectedFailure());
  }
  final status = BookingStatus.values.where((value) => value.name == statusRaw);
  if (status.isEmpty) {
    return const Err(UnexpectedFailure());
  }
  return Success(
    Booking(
      id: id,
      title: title,
      customerName: customerName,
      startAt: startAt,
      status: status.first,
    ),
  );
}

Result<BookingPage> parseBookingPage(Object? json) {
  if (json is! Map) {
    return const Err(UnexpectedFailure());
  }
  final itemsRaw = json['items'];
  final page = json['page'];
  final pageSize = json['pageSize'];
  final totalCount = json['totalCount'];
  if (itemsRaw is! List ||
      page is! int ||
      pageSize is! int ||
      totalCount is! int) {
    return const Err(UnexpectedFailure());
  }
  final items = <Booking>[];
  for (final item in itemsRaw) {
    switch (parseBooking(item)) {
      case Success(:final value):
        items.add(value);
      case Err(:final failure):
        return Err(failure);
    }
  }
  return Success(
    BookingPage(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
    ),
  );
}

Map<String, Object?> bookingToJson(Booking booking) {
  return {
    'id': booking.id,
    'title': booking.title,
    'customerName': booking.customerName,
    'startAt': booking.startAt.toUtc().toIso8601String(),
    'status': booking.status.name,
  };
}

ValidationFailure? parseValidation(Object? json) {
  if (json is! Map) {
    return null;
  }
  final fieldsRaw = json['fields'];
  if (fieldsRaw is! Map) {
    return null;
  }
  final fields = <BookingField, BookingFieldError>{};
  for (final entry in fieldsRaw.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key is! String || value is! String) {
      continue;
    }
    final field = BookingField.values.where((item) => item.name == key);
    final error = BookingFieldError.values.where((item) => item.name == value);
    if (field.isEmpty || error.isEmpty) {
      continue;
    }
    fields[field.first] = error.first;
  }
  if (fields.isEmpty) {
    return null;
  }
  return ValidationFailure(fields);
}
