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

Requires Flutter 3.47.2 / Dart ^3.13.2.

```bash
sh scripts/prebuild.sh
flutter run
```

## Running tests

```bash
sh scripts/run_all_tests.sh
```

## Stack

- **State management:** flutter_bloc, bloc_concurrency
- **Networking:** dio
- **DI:** get_it
- **Serialization:** json_serializable, json_annotation, build_runner

## Known limitations

These were skipped because of the project's scale:

- **Query history is in-memory only.** It isn't kept between launches.
- **Layer boundaries are a convention.** Folders, unlike packages, don't stop one layer importing
  another.
