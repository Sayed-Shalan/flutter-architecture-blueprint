import 'dart:convert';

import 'package:flutter_architecture_blueprint/core/failure/app_failure.dart';
import 'package:flutter_architecture_blueprint/core/result/result.dart';
import 'package:flutter_architecture_blueprint/features/bookings/data/http_booking_repository.dart';
import 'package:flutter_architecture_blueprint/features/bookings/domain/booking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1, 9);
  final base = Uri.parse('https://api.example.test/v1/');

  HttpBookingRepository repository(MockClient client, {Duration? timeout}) {
    return HttpBookingRepository(
      client: client,
      baseUri: base,
      now: () => now,
      timeout: timeout ?? const Duration(seconds: 2),
    );
  }

  test('lists bookings from a page payload', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/v1/bookings');
      expect(request.url.queryParameters['page'], '1');
      expect(request.url.queryParameters['pageSize'], '20');
      return http.Response(
        jsonEncode({
          'items': [
            {
              'id': 'b1',
              'title': 'Studio review',
              'customerName': 'Noura Hassan',
              'startAt': '2026-06-02T11:00:00.000Z',
              'status': 'scheduled',
            },
          ],
          'page': 1,
          'pageSize': 20,
          'totalCount': 1,
        }),
        200,
      );
    });

    final result = await repository(client).list(page: 1);
    final page = (result as Success<BookingPage>).value;
    expect(page.items.single.id, 'b1');
    expect(page.totalCount, 1);
  });

  test('maps 404, 422, and 500 responses', () async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/missing')) {
        return http.Response('{}', 404);
      }
      if (request.method == 'POST') {
        return http.Response(
          jsonEncode({
            'fields': {'startAt': 'mustBeFuture'},
          }),
          422,
        );
      }
      return http.Response('nope', 500);
    });
    final repo = repository(client);

    expect(
      (await repo.getById('missing') as Err<Booking>).failure,
      isA<NotFoundFailure>(),
    );
    expect(
      (await repo.list(page: 1) as Err<BookingPage>).failure,
      isA<UnexpectedFailure>(),
    );
    final rejected = await repo.create(
      BookingDraft(
        title: 'Kickoff',
        customerName: 'Ada',
        startAt: now.add(const Duration(days: 1)),
      ),
    );
    expect(
      (rejected as Err<Booking>).failure,
      const ValidationFailure({
        BookingField.startAt: BookingFieldError.mustBeFuture,
      }),
    );
  });

  test('maps transport failures and malformed JSON', () async {
    final down = repository(
      MockClient((request) async {
        throw http.ClientException('down', request.url);
      }),
    );
    expect(
      (await down.list(page: 1) as Err<BookingPage>).failure,
      isA<NetworkFailure>(),
    );

    final slow = repository(
      MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('{}', 200);
      }),
      timeout: const Duration(milliseconds: 5),
    );
    expect(
      (await slow.getById('b1') as Err<Booking>).failure,
      isA<TimeoutFailure>(),
    );

    final broken = repository(
      MockClient((request) async => http.Response('{', 200)),
    );
    expect(
      (await broken.list(page: 1) as Err<BookingPage>).failure,
      isA<UnexpectedFailure>(),
    );
  });
}
