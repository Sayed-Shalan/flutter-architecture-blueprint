import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';
import '../domain/booking.dart';

class BookingDetailViewModel extends AsyncNotifier<Booking> {
  BookingDetailViewModel(this.id);

  final String id;

  @override
  Future<Booking> build() {
    ref.watch(bookingRepositoryProvider);
    return _load();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<Booking> _load() async {
    final result = await ref.read(bookingRepositoryProvider).getById(id);
    return switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}

final bookingDetailProvider =
    AsyncNotifierProvider.family<BookingDetailViewModel, Booking, String>(
      BookingDetailViewModel.new,
      retry: (_, _) => null,
    );
