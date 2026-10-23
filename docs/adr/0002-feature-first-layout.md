# ADR 0002: Feature-first layout

## Status

Accepted

## Context

A layer-first tree (`presentation/`, `domain/`, `data/` at the root) spreads one feature across the project. This app has one feature, but the layout should still show where the next feature would go.

## Decision

Keep shared failure and result types in `lib/core`. Put the booking board in `lib/features/bookings`, split into `domain`, `data`, and `presentation`. App shell code (router, locale, composition) stays in `lib/app`.

Domain types do not import Flutter or HTTP. Data implements `BookingRepository`. Presentation watches Riverpod providers and does not parse JSON.

## Consequences

A second feature can be added beside `bookings` without moving core types. Cross-feature imports should go through domain interfaces, not another feature's data sources.

## Revisit when

A type is duplicated by a second feature. Move it to `lib/core` at that point, not before.
