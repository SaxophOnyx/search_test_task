# Search Test Task

A typeahead search over Hacker News stories (HN Algolia API), with infinite scroll and suggestions
from past queries.

## Overview

The app uses clean architecture under `lib/src/`, and dependencies point inward:

- `domain/` holds the models, repository interfaces, use cases and domain exceptions. It's pure
  Dart.
- `data/` holds the Dio provider, DTOs, mappers and repository implementations. The repository is
  also the error boundary.
- `core/` holds DI (`get_it`) and the base `AppException`.
- `features/<feature>/` is the presentation layer, sliced by feature into `bloc/`, `screen/` and
  `widgets/`.

Each layer is a folder rather than a separate package, to keep a project this size simple.

## Getting started

Requires Flutter 3.47.2 / Dart ^3.13.2. Runs on Android and iOS. The HN Algolia API is public, so
there are no API keys or config to set up.

```bash
sh scripts/prebuild.sh
flutter run
```

`prebuild.sh` runs `flutter clean` and `flutter pub get`, then `build_runner` to generate the
`*.g.dart` files.

## Running tests

```bash
sh scripts/run_all_tests.sh
```

Unit tests under `test/src/` mirror `lib/src/`. They cover the provider, entity parsing, mappers,
the repository's error mapping, DI, the use case, `SearchBloc` (via `bloc_test`) and
`QueryHistory`. Mocks use `mocktail`.

## Stack

- **State management:** flutter_bloc, bloc_concurrency
- **Networking:** dio
- **DI:** get_it
- **Serialization:** json_serializable, json_annotation, build_runner

## Known limitations

These were skipped because of the project's scale:

- **Query history is in-memory only.** It isn't kept between launches.
- **Layer boundaries are a convention.** Folders don't stop one layer importing another.
- **Data-layer error handling is simplified.** There's no reusable `HttpGuardedProvider` base
  class that bundles the base URL, auth and error handling. The single provider wraps its calls in
  an injected `ApiGuard`, and the repository turns anything unexpected into `UnknownException`.
- **Localization**. App uses hardcoded string for now.
