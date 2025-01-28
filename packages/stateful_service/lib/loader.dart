import 'dart:async';

import 'package:stateful_service/stateful_service.dart';
import 'package:synchronized/synchronized.dart';

/// Utility base class for a service that pre-loads state to be consumed by another service.
///
/// This is useful when a service needs some initial data may be injected from an external source,
/// such as the return value from a create call, into a state management system such as Riverpod.
abstract class Loader<T> extends StatefulService<T?> {
  Loader({required FutureOr<T?> Function() load, super.cache, bool autoInitialize = false})
      : _load = load,
        super(initialState: autoInitialize && load is T? Function() ? load() : null) {
    if (autoInitialize && load is Future<T?> Function()) {
      initialize();
    }
  }

  final FutureOr<T?> Function() _load;

  Future<void> initialize() => update((state) async {
        if (state != null) return state;
        return _load();
      });

  final _refreshLock = Lock();
  Future<void> refresh() async {
    if (_refreshLock.locked) return;
    return _refreshLock.synchronized(() => streamUpdates((_, setSavePoint) async* {
          yield setSavePoint(null);
          yield await _load();
        }));
  }

  Future<void> inject(T state, [bool force = true]) =>
      update((oldState) => oldState == null || force ? state : oldState);

  Future<void> clear() => update((_) => null);
}
