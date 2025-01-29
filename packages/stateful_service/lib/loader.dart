import 'dart:async';

import 'package:stateful_service/stateful_service.dart';

/// Utility base class for a service that pre-loads state to be consumed by another service.
///
/// This is useful when a service needs some initial data may be injected from an external source,
/// such as the return value from a create call, into a state management system such as Riverpod.
abstract class Loader<T> extends StatefulService<T?> {
  Loader({required FutureOr<T?> Function() load, super.cache, super.verboseLogging, bool autoInitialize = false})
      : _load = load,
        super(initialState: autoInitialize && load is T? Function() ? load() : null) {
    if (autoInitialize && load is Future<T?> Function()) {
      initialize();
    }
  }

  final FutureOr<T?> Function() _load;

  var _isWorking = false;
  Future<void> initialize() {
    if (state.value != null || _isWorking) return Future.value();
    _isWorking = true;
    return update((state) => _load()).whenComplete(() => _isWorking = false);
  }

  Future<void> refresh() {
    if (_isWorking) return Future.value();
    _isWorking = true;
    return streamUpdates((_, setSavePoint) async* {
      yield setSavePoint(null);
      yield await _load();
    }).whenComplete(() => _isWorking = false);
  }

  Future<void> inject(T state, [bool force = true]) {
    if (this.state.value != null && !force) return Future.value();
    return set(state);
  }

  Future<void> clear() => set(null);
}
