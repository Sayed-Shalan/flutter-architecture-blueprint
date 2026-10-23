# ADR 0004: One repository, two data sources

## Status

Accepted

## Context

The sample has to run with `flutter run` and no backend, and it still has to show a real HTTP mapping that tests can exercise.

## Decision

`BookingRepository` is the boundary. `InMemoryBookingRepository` is the default. `HttpBookingRepository` is selected when the app is started with `--dart-define=API_BASE_URL=...`.

Both implementations validate drafts with `validateBookingDraft` before storing or sending. The HTTP client additionally maps status codes:

| Status | Failure |
| --- | --- |
| 404 | `NotFoundFailure` |
| 422 with `fields` | `ValidationFailure` |
| other non-2xx | `UnexpectedFailure` |
| timeout | `TimeoutFailure` |
| `ClientException` or `SocketException` | `NetworkFailure` |

Page requests use `page` and `pageSize` (page 1 is the first page). The list view model appends pages and ignores `loadMore` while a request is already in flight.

## Consequences

Widget tests override the repository and never open a socket. The HTTP contract is documented in the README and covered by `MockClient` tests. There is no authentication. The in-memory store is wiped when the process exits.

## Revisit when

The API gains cursors, authentication, or conflict handling on create.
