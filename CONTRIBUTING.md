# Contributing

Issues and pull requests are welcome. Please keep changes focused.

## Before opening a pull request

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Use the Flutter stable SDK this repository is developed against (3.41.x). Do not commit secrets, signing material, or generated build output.

## Architecture changes

If you change a decision recorded under `docs/adr/`, add a new ADR or update the status of the old one. Describe the code that exists, not a design you intend to build later.
