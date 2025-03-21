## 6.0.1

 - Fix `riverpod_stateful_service_generator` builder parameter.

## 6.0.0

 - BREAKING: Update `riverpod_stateful_service_generator` dependency major versions:
   - `analyzer` to `7.0.0`
   - `source_gen` to `2.0.0`

## 5.2.0

- Add `StatefulService.set` to directly set the state of a concrete value without going through a
  loading state.
- Various fixes for `Loader` to prevent excessive state updates.

## 5.1.1

- Re-apply changes from 5.0.4 that were lost in the 5.1.0 release.

## 5.1.0

- Add `Loader` utility class.

## 5.0.4

- Don't crash on empty stream in `streamUpdates`

## 5.0.3

- Ensure that state updates are properly reflected in `values`-stream.
- Add `isInitialized` getter to `StatefulService`

## 5.0.2

- `shouldBeEmitted` should only be applied to updates that change the state's inner value.
- `riverpod_stateful_service` now logs errors instead of throwing exceptions when there are missing
  imports.

## 5.0.1

- Fixed riverpod_stateful_service `asAsyncValue` to use new service state error type.

## 5.0.0

- BREAKING: The `setSavePoint` function now takes the new save point as a parameter, instead of
  using the current state, to avoid race conditions.
- BREAKING: Split the service error state out into a separate type
- BREAKING: Renamed `map` and `mapOrNull` to `when` and `whenOrNull` to be more in line with
  traditional naming and avoid confusion.
- BREAKING: Renamed `mapValue` to `map` to be more in line with traditional naming and avoid
  confusion.

## 4.1.0

- shared_preferences_stateful_service_cache encoders and decoders now return a FutureOr<String> to
  allow offloading of expensive operations to a separate isolate.
- Fixed riverpod_stateful_service to use new name for `ServiceState.value`.
- Renamed riverpod_stateful_service_generator extension methods to reflect the new name for
  `ServiceState.value`.

## 4.0.0

- BREAKING: Renamed the `ServiceState.state` to `ServiceState.value`.
- BREAKING: Created a separate `ServiceError` type instead of using a tuple.
- Added convenience methods `map`, `mapOrNull`, and `mapValue` on `ServiceState`.
- Changed shared_preferences_stateful_service_cache to use the new async API for shared_preferences.
- Added an init function to allow for potentially asynchronous initialization of the service
  state before initialization is reported complete.
- Added some more logging, and a `verboseLogging` flag.

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
