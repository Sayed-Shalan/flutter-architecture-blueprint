import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/failure/app_failure.dart';
import '../../../core/result/result.dart';
import '../domain/booking.dart';

class BookingListState {
  const BookingListState({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.isLoadingMore,
    this.loadMoreFailure,
  });

  final List<Booking> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool isLoadingMore;
  final AppFailure? loadMoreFailure;

  bool get hasMore => page * pageSize < totalCount;

  BookingListState copyWith({
    List<Booking>? items,
    int? page,
    int? totalCount,
    bool? isLoadingMore,
    AppFailure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) {
    return BookingListState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : loadMoreFailure ?? this.loadMoreFailure,
    );
  }
}

class BookingListViewModel extends AsyncNotifier<BookingListState> {
  static const pageSize = 20;

  @override
  Future<BookingListState> build() {
    ref.watch(bookingRepositoryProvider);
    return _firstPage();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_firstPage);
  }

  /// Replaces the first page without forcing the loading spinner first.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_firstPage);
  }

  /// Ignores overlapping calls so a double tap cannot request the same page twice.
  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }
    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true),
    );
    final result = await ref
        .read(bookingRepositoryProvider)
        .list(page: current.page + 1, pageSize: pageSize);
    final latest = state.asData?.value;
    if (latest == null) {
      return;
    }
    switch (result) {
      case Success(:final value):
        state = AsyncData(
          latest.copyWith(
            items: [...current.items, ...value.items],
            page: value.page,
            totalCount: value.totalCount,
            isLoadingMore: false,
            clearLoadMoreFailure: true,
          ),
        );
      case Err(:final failure):
        state = AsyncData(
          latest.copyWith(isLoadingMore: false, loadMoreFailure: failure),
        );
    }
  }

  Future<BookingListState> _firstPage() async {
    final page = await _page(1);
    return BookingListState(
      items: page.items,
      page: page.page,
      pageSize: page.pageSize,
      totalCount: page.totalCount,
      isLoadingMore: false,
    );
  }

  Future<BookingPage> _page(int page) async {
    final result = await ref
        .read(bookingRepositoryProvider)
        .list(page: page, pageSize: pageSize);
    return switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}

final bookingListProvider =
    AsyncNotifierProvider<BookingListViewModel, BookingListState>(
      BookingListViewModel.new,
      // Riverpod retries failed providers by default. This screen shows the
      // error and waits for an explicit retry instead.
      retry: (_, _) => null,
    );
