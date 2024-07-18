import 'dart:async';

import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

mixin StatefulServiceCache<S> {
  Future<S?> init();

  Future<void> close();

  Future<void> put(S state);

  Future<void> clear();
}

/// A base class for representing a stateful service.
///
/// The service state is available through the [state] value stream but the only way to update it is by returning/
/// yielding new values from the provided callbacks. This allows us to serialize all state changes and reduce the risk
/// of race conditions.
abstract class StatefulService<S> {
  /// Creates a new [StatefulService] with the provided [initialState].
  ///
  /// [name] is used only for logging purposes and defaults to this service's runtime type. A custom [Logger] can be
  /// supplied with the [logger] parameter.
  ///
  /// If a cache is supplied, each updated state is persisted in the cache before it is emitted. If saving to the cache
  /// fails, the updated state will still be emitted. A [cacheValidator] can be supplied to determine if the cached state
  /// is valid and should be used in the current context.
  ///
  /// By default, a new state is emitted to listeners if it does not compare equal to the current state, but this
  /// can be overridden using the [shouldStateBeEmitted] function parameter.
  StatefulService({
    required S initialState,
    String? name,
    Logger? logger,
    StatefulServiceCache<S>? cache,
    bool Function(S)? cacheValidator,
    bool Function(S previousState, S newState)? shouldStateBeEmitted,
  })  : _state = initialState,
        _name = name,
        _logger = logger ?? Logger(),
        _cache = cache,
        _shouldStateBeEmitted = shouldStateBeEmitted ?? ((a, b) => a != b) {
    final cache = _cache;
    if (cache == null) {
      initComplete = Future.value(null);
    } else {
      initComplete = _update(() async {
        final cachedState = await cache.init().onError((err, trace) {
          _logger.e('[$name] Failed to initialize ${cache.runtimeType}', error: err, stackTrace: trace);
          return null;
        });
        if (cachedState != null && cacheValidator?.call(cachedState) != false) {
          await _addState(cachedState);
          _logger.d('[$name] State cache initialized');
        } else {
          await cache.put(initialState);
        }
      }, false);
    }
  }

  S _state;
  final String? _name;
  final Logger _logger;
  final StreamController<S> _controller = StreamController.broadcast();
  final StatefulServiceCache<S>? _cache;
  final bool Function(S state1, S state2) _shouldStateBeEmitted;
  final Lock _lock = Lock();
  bool _isUpdating = false;
  bool _ignoreUpdates = false;

  String get name => _name ?? runtimeType.toString();

  late final Future<void> initComplete;

  Stream<S> get stream => _controller.stream;

  bool get isClosed => _controller.isClosed;

  bool get isUpdating => _isUpdating;

  S get state => _state;

  /// Listens to the state stream and calls [onData] whenever a new state is emitted.
  StreamSubscription<S> listen(void Function(S value) onData) => _controller.stream.listen(onData);

  /// Clears this service's state cache. Note that this will not affect the current state of the service.
  Future<void> clearCache() async => _cache?.clear();

  /// Makes a single update to this service's state with the value returned from [update].
  ///
  /// If [ignoreConcurrentUpdates] is true, any other state updates will be dropped, rather than queued, until the
  /// [Future] returned by [update] completes.
  @protected
  @visibleForTesting
  Future<void> update(FutureOr<S> Function(S state) update, {bool ignoreConcurrentUpdates = false}) =>
      _update(() async => _addState(await update(state)), ignoreConcurrentUpdates);

  /// Performs a series of updates of service's state with the values emitted from the stream returned by [updates]. The
  /// service state will be locked (no other updates can take place) until the stream completes.
  ///
  /// If the stream emits an error at any point, the service's state will be reverted to the value it had before the
  /// execution of the [updates] function started.
  ///
  /// If [ignoreConcurrentUpdates] is true, any other update requests will be dropped, rather than queued, until the
  /// [Stream] returned by [updates] has completed.
  @protected
  @visibleForTesting
  Future<void> streamUpdates(Stream<S> Function(S state) updates, {bool ignoreConcurrentUpdates = false}) =>
      _update(() async {
        final previous = state;
        try {
          await updates(previous).forEach(_addState);
        } catch (_) {
          await _addState(previous);
          rethrow;
        }
      }, ignoreConcurrentUpdates);

  Future<void> _update(Future<void> Function() f, bool ignoreConcurrentUpdates) {
    if (isClosed) throw StateError('[$name] Cannot update a closed service');

    final ignoreUpdates = _ignoreUpdates;
    if (ignoreUpdates) {
      _logger.d('[$name] Ignoring concurrent state update');
      return Future.value(null);
    } else if (ignoreConcurrentUpdates) {
      _ignoreUpdates = true;
    }
    _isUpdating = true;
    return _lock.synchronized(() async {
      if (isClosed) {
        _logger.w('[$name] Already closed, ignoring update');
      } else {
        await f();
      }
    }).whenComplete(() {
      _ignoreUpdates = false;
      _isUpdating = false;
    });
  }

  Future<S> _addState(S state) async {
    if (_shouldStateBeEmitted(_state, state) && !isClosed) {
      final cache = _cache;
      if (cache != null) {
        try {
          await cache.put(state);
          _logger.d('[$name] State written to cache');
        } catch (err, trace) {
          _logger.e('[$name] Failed to write to ${_cache.runtimeType}', error: err, stackTrace: trace);
        }
      }
      _state = state;
      _controller.add(state);
    }
    return state;
  }

  /// Closes the service. Any in-flight update operations will be discarded and further calls to update the service
  /// state will result in errors.
  @mustCallSuper
  Future<void> close() async {
    await initComplete;
    _logger.d('[$name] Closing');
    await _controller.close();
    await _cache?.close();
  }
}
