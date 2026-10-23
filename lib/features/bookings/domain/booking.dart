enum BookingStatus { scheduled, completed, cancelled }

class Booking {
  const Booking({
    required this.id,
    required this.title,
    required this.customerName,
    required this.startAt,
    required this.status,
  });

  final String id;
  final String title;
  final String customerName;
  final DateTime startAt;
  final BookingStatus status;

  @override
  bool operator ==(Object other) {
    return other is Booking &&
        other.id == id &&
        other.title == title &&
        other.customerName == customerName &&
        other.startAt == startAt &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, title, customerName, startAt, status);
}

/// Input collected by the create form before the repository accepts it.
class BookingDraft {
  const BookingDraft({
    required this.title,
    required this.customerName,
    required this.startAt,
  });

  final String title;
  final String customerName;
  final DateTime? startAt;
}

class BookingPage {
  const BookingPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<Booking> items;
  final int page;
  final int pageSize;
  final int totalCount;

  bool get hasMore => page * pageSize < totalCount;
}
