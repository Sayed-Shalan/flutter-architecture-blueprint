import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../features/bookings/data/demo_bookings.dart';
import '../features/bookings/data/http_booking_repository.dart';
import '../features/bookings/data/in_memory_booking_repository.dart';
import '../features/bookings/domain/booking_repository.dart';

typedef Clock = DateTime Function();

enum DataSourceKind { inMemory, http }

class AppConfig {
  const AppConfig.inMemory()
    : dataSource = DataSourceKind.inMemory,
      apiBaseUri = null;

  const AppConfig.http(Uri this.apiBaseUri) : dataSource = DataSourceKind.http;

  final DataSourceKind dataSource;
  final Uri? apiBaseUri;
}

/// Set at build time: `--dart-define=API_BASE_URL=https://example.test/`.
const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

final clockProvider = Provider<Clock>((ref) => DateTime.now);

final appConfigProvider = Provider<AppConfig>((ref) {
  if (_apiBaseUrl.isEmpty) {
    return const AppConfig.inMemory();
  }
  return AppConfig.http(Uri.parse(_apiBaseUrl));
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final clock = ref.watch(clockProvider);
  final config = ref.watch(appConfigProvider);
  return switch (config.dataSource) {
    DataSourceKind.inMemory => InMemoryBookingRepository(
      now: clock,
      seed: demoBookings(clock()),
    ),
    DataSourceKind.http => HttpBookingRepository(
      client: ref.watch(httpClientProvider),
      baseUri: config.apiBaseUri!,
      now: clock,
    ),
  };
});
