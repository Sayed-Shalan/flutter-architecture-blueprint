# ADR 0001: Riverpod for state and dependency injection

## Status

Accepted

## Context

The booking board needs a testable way to load, retry, and create bookings, and a single place to choose between the in-memory demo and the HTTP repository. GetX bundles routing, service location, and state. Bloc would add events and a framework for a screen set this small.

## Decision

Use `flutter_riverpod` 3.3.x (the version resolved by the Flutter 3.41.6 SDK constraint).

- `Provider` constructs `AppConfig`, the clock, the HTTP client, and `BookingRepository`.
- `AsyncNotifier` owns the list and detail screens because they load asynchronously and expose `retry`, `refresh`, and `loadMore`.
- `Notifier` owns create-booking submission state.
- Widgets keep `TextEditingController`s. That state does not need to outlive the route.
- Tests override `bookingRepositoryProvider` or a view-model provider on a `ProviderContainer`.
- List and detail providers set `retry` to a function that returns null. Riverpod 3 otherwise retries failed loads with exponential backoff, which would hide the error state this UI is meant to show. Retry is a button.

## Consequences

Overrides are explicit, so widget tests do not need a service locator reset. A future migration to code generation is unnecessary at this size. Riverpod 3 family notifiers take their argument in the constructor (`BookingDetailViewModel(this.id)`), which is the API this code uses.

## Revisit when

The app grows past a handful of features, or a team standard requires Bloc.
