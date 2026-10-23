import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/failure/app_failure.dart';
import '../../../core/result/result.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_validation.dart';
import 'booking_json.dart';

/// Talks to a JSON API:
///
/// `GET  {base}/bookings?page=&pageSize=`
/// `GET  {base}/bookings/{id}`
/// `POST {base}/bookings`
///
/// `422` bodies may be `{"fields":{"title":"required"}}`.
class HttpBookingRepository implements BookingRepository {
  HttpBookingRepository({
    required http.Client client,
    required Uri baseUri,
    required DateTime Function() now,
    Duration timeout = const Duration(seconds: 10),
  }) : _client = client,
       _baseUri = baseUri,
       _now = now,
       _timeout = timeout;

  final http.Client _client;
  final Uri _baseUri;
  final DateTime Function() _now;
  final Duration _timeout;

  @override
  Future<Result<Booking>> create(BookingDraft draft) {
    final validation = validateBookingDraft(draft, now: _now());
    if (validation != null) {
      return Future.value(Err(validation));
    }
    final body = jsonEncode({
      'title': draft.title.trim(),
      'customerName': draft.customerName.trim(),
      'startAt': draft.startAt!.toUtc().toIso8601String(),
    });
    return _send(
      () => _client.post(
        _endpoint(['bookings']),
        headers: _jsonHeaders,
        body: body,
      ),
      (response) => parseBooking(_decode(response.body)),
    );
  }

  @override
  Future<Result<Booking>> getById(String id) {
    return _send(
      () => _client.get(_endpoint(['bookings', id]), headers: _jsonHeaders),
      (response) => parseBooking(_decode(response.body)),
    );
  }

  @override
  Future<Result<BookingPage>> list({required int page, int pageSize = 20}) {
    return _send(
      () => _client.get(
        _endpoint(['bookings'], {'page': '$page', 'pageSize': '$pageSize'}),
        headers: _jsonHeaders,
      ),
      (response) => parseBookingPage(_decode(response.body)),
    );
  }

  Future<Result<T>> _send<T>(
    Future<http.Response> Function() send,
    Result<T> Function(http.Response response) decode,
  ) async {
    try {
      final response = await send().timeout(_timeout);
      if (response.statusCode == 404) {
        return const Err(NotFoundFailure());
      }
      if (response.statusCode == 422) {
        final validation = parseValidation(_decode(response.body));
        if (validation == null) {
          return const Err(UnexpectedFailure());
        }
        return Err(validation);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const Err(UnexpectedFailure());
      }
      return decode(response);
    } on TimeoutException {
      return const Err(TimeoutFailure());
    } on http.ClientException {
      return const Err(NetworkFailure());
    } on SocketException {
      return const Err(NetworkFailure());
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }

  Uri _endpoint(List<String> segments, [Map<String, String>? query]) {
    return _baseUri.replace(
      pathSegments: [
        ..._baseUri.pathSegments.where((segment) => segment.isNotEmpty),
        ...segments,
      ],
      queryParameters: query,
    );
  }

  Object? _decode(String body) {
    if (body.isEmpty) {
      return null;
    }
    return jsonDecode(body);
  }
}

const _jsonHeaders = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};
