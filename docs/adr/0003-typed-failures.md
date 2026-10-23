# ADR 0003: Typed failures instead of thrown exceptions

## Status

Accepted

## Context

Network, timeout, validation, not-found, and unexpected errors need different UI. String matching on `Exception.toString()` breaks as soon as a message is localized or a library changes its wording.

## Decision

Repositories return `Result<T>` (`Success` or `Err`). `AppFailure` is a sealed type:

- `NetworkFailure`
- `TimeoutFailure`
- `ValidationFailure` with `BookingField` codes, not English sentences
- `NotFoundFailure`
- `UnexpectedFailure`

View models throw the failure only so Riverpod's `AsyncValue` can represent the first-page error. The widget switches on the failure type and reads copy from ARB files. `UnexpectedFailure` carries no message, so a decode error cannot leak response text into the UI.

## Consequences

New failure cases are a compile-time exhaustiveness change in `failureMessage`. Validation copy is translated in English and Arabic without the repository knowing either language.

## Revisit when

A failure needs structured payload besides field codes, such as a retry-after duration.
