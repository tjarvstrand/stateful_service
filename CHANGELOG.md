## 3.0.0

- BREAKING: `StatefulService`s now wrap their state in a `ServiceState` object.
- Add some more convenience methods to riverpod_stateful_service.
- Remove exports of things in `riverpod_annotation` from `riverpod_stateful_service_annotation`, since
  we cannot export all of them and it causes some confusion that is sometimes not detected until run
  time.
- `riverpod_stateful_service_generator` now requires both `riverpod` and `riverpod_stateful_service` to
  be imported in the file where the `@riverpodService` annotation is used.

## 2.0.3

- Hide invalid exports in riverpod_stateful_service_annotation

## 2.0.2

- Bump riverpod to 2.6.1.
- Handle services that store ref as a member variable using 'this'.

## 2.0.1

- Export `riverpod`-annotation and `ProviderFor` from riverpod_stateful_service_annotation.
- Fixes for indicators for isUpdating and ignoring concurrent updates.

## 2.0.0

- Use logging-package instead of logger.
- Allow `streamUpdates` to set a savepoint for rollback.
- Avoid `LateInitializationError`s in generated Riverpod services.

## 1.1.1

Improve generator output.

## 1.1.0

Add riverpod_stateful_service_generator and riverpod_stateful_service_annotation.

## 1.0.0+2

Add more documentation and usage examples.

## 1.0.0+1

- Updates to the README.
- Fixes to pubspec.yaml to improve pana score.
- Fix formatting and add more documentation.

## 1.0.0

Initial release
