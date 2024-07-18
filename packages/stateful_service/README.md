## Features

This package provides a simple and convenient way to represent stateful services in Dart. A 
service's state is represented using a single value.

All operations on the service's state are serialized using a single event queue which reduces the
complexity of managing concurrent state changes and reduces the risk of race conditions. State 
updates can be implemented either as a `Future`, or as a `Stream` for more complex operations.

If an update fails (whether it's a `Future` or a `Stream`), the service will automatically revert to
the state it had before the update started. This makes it simple to implement more complex state 
changes such as optimistic UI updates. 

## Getting started

To use this package, add `stateful_service` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  stateful_service: ^0.0.1
```

Then, import the package in your Dart code and create a subclass of `StatefulService<T>`.

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

## Additional information

NOTE: To further reduce the risk of race conditions and other unexpected behavior, it is recommended
to use immutable collection types for any collections that are part of the service's state. Some
popular packages that provide such types are `built_collection`, `dartz` and 
`fast_immutable_collections`.
