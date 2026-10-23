import '../domain/booking.dart';

/// Stable ids so deep links in the offline demo stay predictable.
List<Booking> demoBookings(DateTime now) {
  return [
    Booking(
      id: 'b1',
      title: 'Studio review',
      customerName: 'Noura Hassan',
      startAt: now.add(const Duration(days: 1, hours: 2)).toUtc(),
      status: BookingStatus.scheduled,
    ),
    Booking(
      id: 'b2',
      title: 'Site walkthrough',
      customerName: 'Karim Adel',
      startAt: now.add(const Duration(days: 2, hours: 4)).toUtc(),
      status: BookingStatus.scheduled,
    ),
    Booking(
      id: 'b3',
      title: 'Design critique',
      customerName: 'Lina Farouk',
      startAt: now.add(const Duration(days: 3)).toUtc(),
      status: BookingStatus.completed,
    ),
  ];
}
