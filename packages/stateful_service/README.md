
[![pub package](https://img.shields.io/pub/v/stateful_service.svg?label=stateful_service&color=blue)](https://pub.dev/packages/stateful_service)
[![popularity](https://img.shields.io/pub/popularity/stateful_service?logo=dart)](https://pub.dev/packages/stateful_service/score)
[![likes](https://img.shields.io/pub/likes/stateful_service?logo=dart)](https://pub.dev/packages/stateful_service/score)
[![pub points](https://img.shields.io/pub/points/stateful_service?logo=dart)](https://pub.dev/packages/stateful_service/score)
![building](https://github.com/tjarvstrand/stateful_service/workflows/stateful_service/badge.svg)
## Features

This package provides a stream-based way to represent stateful services in Dart.

Primary benefits of using this package include:

#### Simplicity

The service's state is represented using a single (preferably immutable) value, that can only be 
changed from inside the service itself.

#### Isolation

All operations on the service's state are serialized using a single event queue, which reduces the 
complexity of managing concurrent state changes and minimizes the risk of race conditions.

#### Safety

If an update fails, the service will automatically revert to the state it
had before the update started. This makes it simple to implement more complex state changes such 
as optimistic UI updates, without having to worry about leaving the service in an inconsistent
state.

#### Portability

Since the service is based on Dart's own primitives, it can be used with any state management 
solution, or even without one.

#### Transferable knowledge

Streams are an incredibly powerful concept that is widely used across the entire software 
development industry. Unlike things like `Listenable`s, `Notifier`s, etc., once you familiarize 
yourself with streams, you'll be able to transfer that knowledge to almost any other framework or 
programming language that you'll pick up in the future.

## Getting started

To use this package, add `stateful_service` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  stateful_service: ^1.0.0
```

### Creating a service

To create a service, import the package in your Dart code and create a subclass of
`StatefulService<T>`.

```dart
import 'package:stateful_service/example.dart';

class UserService extends StatefulService<User> {
  UserService({required super.initialState});
  
  ...

  /// Updates the user's name.
  Future<void> updateName(String newName) => update((user) async {
    await _api.updateName(newName);
    return user.withName(newName);
  });

  /// Updates the user's name, updating listeners (e.g. the UI) optimistically.
  Future<void> updateNameOptimistic(String newName) => streamUpdates((user) async* {
    yield user.withName(newName);
    await _api.updateName(newName);
  });
}
```

### Consuming a service

`StatefulService`s are stream-based, which means that you can consume state updates the same way you
would consume any other stream in Dart, with the added convenience of always having access to the
service's current state via the `state` getter.

E.g. using a `StreamBuilder` in Flutter:

```dart

Widget build(BuildContext context) => StreamBuilder(
  stream: service.stream,
  builder: (_, __) => MyWidget(service.state),
);
```

## Additional information

NOTE: To further reduce the risk of race conditions and other unexpected behavior, it is recommended
to use immutable collection types for any collections that are part of the service's state. Some
popular packages that provide such types are `built_collection`, `dartz` and 
`fast_immutable_collections`.

### Related packages

 - [shared_preferences_stateful_service_cache](https://pub.dev/packages/shared_preferences_stateful_service_cache):
   A cache implementation for `StatefulService` that uses `SharedPreferences` to persist the service's
   state between app restarts.
 - [riverpod_stateful_service](https://pub.dev/packages/riverpod_stateful_service): A Riverpod
   provider for `StatefulService`s.
