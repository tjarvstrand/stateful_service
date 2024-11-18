import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

mixin StatefulServiceCache<S> {
  /// Initializes the cache and returns the cached state, if any.
  Future<S?> init();

  /// Closes the cache.
  Future<void> close();

  /// Persists the provided state in the cache.
  Future<void> put(S state);

  /// Clears the cache.
  Future<void> clear();
}

sealed class ServiceState<T> {
  T get value;
  Object? get error;
  StackTrace? get stackTrace;
  bool get isUpdating;

  T2 when<T2>({
    required T2 Function(ServiceStateIdle<T>) idle,
    required T2 Function(ServiceStateUpdating<T>) updating,
    required T2 Function(ServiceStateError<T>) error,
  });

  T2? whenOrNull<T2>({
    T2 Function(ServiceStateIdle<T>)? idle,
    T2 Function(ServiceStateUpdating<T>)? updating,
    T2 Function(ServiceStateError<T>)? error,
  });

  ServiceState<T2> map<T2>(T2 Function(T) f);
}

class ServiceStateUpdating<T> extends ServiceState<T> with EquatableMixin {
  ServiceStateUpdating._(this.value, {required this.wasUpdating});

  @override
  final T value;

  /// False if this was the first state that was emitted as part of an update operation.
  final bool wasUpdating;

  @override
  bool get isUpdating => true;

  @override
  final Object? error = null;

  @override
  final StackTrace? stackTrace = null;

  @override
  List<Object?> get props => [value, wasUpdating];

  @override
  T2 when<T2>({
    required T2 Function(ServiceStateIdle<T>) idle,
    required T2 Function(ServiceStateUpdating<T>) updating,
    required T2 Function(ServiceStateError<T>) error,
  }) =>
      updating(this);

  @override
  T2? whenOrNull<T2>({
    T2 Function(ServiceStateIdle<T>)? idle,
    T2 Function(ServiceStateUpdating<T>)? updating,
    T2 Function(ServiceStateError<T>)? error,
  }) =>
      updating?.call(this);

  @override
  ServiceState<T2> map<T2>(T2 Function(T) f) => ServiceStateUpdating._(f(value), wasUpdating: wasUpdating);
}

class ServiceStateIdle<T> extends ServiceState<T> with EquatableMixin {
  ServiceStateIdle._(this.value);

  @override
  final T value;

  @override
  bool isUpdating = false;

  @override
  final Object? error = null;

  @override
  final StackTrace? stackTrace = null;

  @override
  List<Object?> get props => [value];

  @override
  T2 when<T2>({
    required T2 Function(ServiceStateIdle<T>) idle,
    required T2 Function(ServiceStateUpdating<T>) updating,
    required T2 Function(ServiceStateError<T>) error,
  }) =>
      idle(this);

  T2? whenOrNull<T2>({
    T2 Function(ServiceStateIdle<T>)? idle,
    T2 Function(ServiceStateUpdating<T>)? updating,
    T2 Function(ServiceStateError<T>)? error,
  }) =>
      idle?.call(this);

  ServiceState<T2> map<T2>(T2 Function(T) f) => ServiceStateIdle._(f(value));
}

class ServiceStateError<T> extends ServiceState<T> with EquatableMixin {
  ServiceStateError._(this.value, this.error, this.stackTrace);

  @override
  final T value;

  @override
  bool get isUpdating => false;

  @override
  final Object error;

  @override
  final StackTrace stackTrace;

  @override
  List<Object?> get props => [value, error, stackTrace];

  @override
  T2 when<T2>({
    required T2 Function(ServiceStateIdle<T>) idle,
    required T2 Function(ServiceStateUpdating<T>) updating,
    required T2 Function(ServiceStateError<T>) error,
  }) =>
      error(this);

  T2? whenOrNull<T2>({
    T2 Function(ServiceStateIdle<T>)? idle,
    T2 Function(ServiceStateUpdating<T>)? updating,
    T2 Function(ServiceStateError<T>)? error,
  }) =>
      error?.call(this);

  ServiceState<T2> map<T2>(T2 Function(T) f) => ServiceStateError._(f(value), error, stackTrace);
}

/// A base class for representing a stateful service.
///
/// The service state is available through the [values] value stream but the only way to update it is by returning/
/// yielding new values from the provided callbacks. This allows us to serialize all state changes and reduce the risk
/// of race conditions.
abstract class StatefulService<S> {
  /// Creates a new [StatefulService] with the provided [initialState].
  ///
  /// [name] is used only for logging purposes and defaults to this service's runtime type. A custom [Logger] can be
  /// supplied with the [logger] parameter.
  ///
  /// [init] is an optional function that can be used to asynchronously initialize the state of the service. If provided
  /// it will be called with either the initial state or the state loaded from the cache, if any. The value returned
  /// from this function will be emitted as the first state update, after which the [initComplete] future will also be
  /// complete.
  ///
  /// If a cache is supplied, it's contents will be loaded as the first state update. After that, each updated state is
  /// persisted in the cache before it is emitted. If saving to the cache fails, the updated state will still be
  /// emitted. A [cacheValidator] can be supplied to determine if the cached state is valid and should be used in the
  /// current context.
  ///
  /// By default, a new state is emitted to listeners if it does not compare equal to the current state, but this
  /// can be overridden using the [shouldStateBeEmitted] function parameter.
  StatefulService({
    required S initialState,
    String? name,
    Logger? logger,
    FutureOr<S> Function(S)? init,
    StatefulServiceCache<S>? cache,
    bool Function(S)? cacheValidator,
    bool Function(S previousState, S newState)? shouldStateBeEmitted,
    this.verboseLogging = false,
  })  : _state = init == null
            ? ServiceStateIdle._(initialState) as ServiceState<S>
            : ServiceStateUpdating._(initialState, wasUpdating: false),
        _name = name,
        _cache = cache,
        _shouldStateBeEmitted = shouldStateBeEmitted ?? ((a, b) => a != b) {
    _logger = logger ?? Logger(runtimeType.toString());
    final cache = _cache;

    Future<S> runInit(S initialState) async {
      try {
        final state = await init?.call(initialState) ?? initialState;
        await _addState(ServiceStateIdle._(state));
        return state;
      } catch (error, trace) {
        _logger.severe('[${this.name}] Failed to run service init function', error, trace);
        await _addState(ServiceStateError._(initialState, error, trace));
        return initialState;
      }
    }

    if (cache == null) {
      initComplete = _lock.synchronized(() => runInit(initialState));
    } else {
      initComplete = _lock.synchronized(() async {
        final cachedState = await cache.init().onError((err, trace) {
          _logger.severe('[${this.name}] Failed to initialize ${cache.runtimeType}', err, trace);
          return null;
        });
        if (cachedState != null && cacheValidator?.call(cachedState) != false) {
          _logger.fine('[${this.name}] State cache initialized');
          return runInit(cachedState);
        } else {
          return runInit(initialState);
        }
      });
    }
  }

  ServiceState<S> _state;
  final String? _name;
  late final Logger _logger;
  final StreamController<ServiceState<S>> _controller = StreamController.broadcast();
  final StatefulServiceCache<S>? _cache;
  final bool Function(S state1, S state2) _shouldStateBeEmitted;
  final Lock _lock = Lock();
  bool _isUpdating = false;
  bool _ignoreUpdates = false;
  final bool verboseLogging;

  /// The provided name of this service, or the runtime type if none was provided.
  String get name => _name ?? runtimeType.toString();

  /// A [Future] that completes when the service has finished initializing. It will contain the state's first emitted
  /// state.
  late final Future<S> initComplete;

  /// This stream emits the service's state whenever it changes, it will never emit errors.
  Stream<S> get values => _controller.stream.expand((v) sync* {
        if (v is ServiceStateUpdating<S> && v.wasUpdating || v is ServiceStateIdle<S> && v.error != null) {
          yield v.value;
        }
      });

  /// This stream emits the service's state whenever it changes, it will never emit errors.
  Stream<ServiceState<S>> get states => _controller.stream;

  /// Returns true if this service has been closed. If this returns true, all calls to update the service's state will
  /// fail.
  bool get isClosed => _controller.isClosed;

  /// Returns true if this service is currently processing an update call.
  bool get isUpdating => _isUpdating;

  /// The service's current state.
  ServiceState<S> get state => _state;

  /// Listens to the state stream and calls [onData] whenever a new state is emitted.
  StreamSubscription<ServiceState<S>> listen(void Function(ServiceState<S> value) onData) => states.listen(onData);

  /// Clears this service's state cache. Note that this will not affect the current state of the service.
  Future<void> clearCache() async => _cache?.clear();

  /// Makes a single update to this service's state with the value returned from [update].
  ///
  /// If [ignoreConcurrentUpdates] is true, any other state updates will be dropped, rather than queued, until the
  /// [Future] returned by [update] completes.
  @protected
  @visibleForTesting
  Future<void> update(FutureOr<S> Function(S state) update, {bool ignoreConcurrentUpdates = false}) =>
      streamUpdates((s, __) {
        final u = update(s);
        if (u is Future<S>) {
          return Stream.fromFuture(u);
        }
        return Stream.value(u);
      }, ignoreConcurrentUpdates: ignoreConcurrentUpdates);

  /// Performs a series of updates of service's state with the values emitted from the stream returned by [updates]. The
  /// service state will be locked (no other updates can take place) until the stream completes. [update] receives two
  /// arguments; the service's current state, and a function to call to save the current state as a savepoint.
  ///
  /// If the stream emits an error at any point, the service's state will be reverted to the the last save point or, if
  /// no save-call has been made, the state it had before the execution of the [updates] function started.
  ///
  /// If [ignoreConcurrentUpdates] is true, any other update requests will be dropped, rather than queued, until the
  /// [Stream] returned by [updates] has completed.
  @protected
  @visibleForTesting
  Future<void> streamUpdates(
    Stream<S> Function(S state, S Function(S) setSavePoint) updates, {
    bool ignoreConcurrentUpdates = false,
  }) {
    if (isClosed) throw StateError('[$name] Cannot update a closed service');

    if (_ignoreUpdates) {
      _logger.fine('[$name] Ignoring concurrent state update');
      return Future.value(null);
    } else if (ignoreConcurrentUpdates) {
      _ignoreUpdates = true;
    }

    return _lock.synchronized(() async {
      if (isClosed) {
        _logger.warning('[$name] Already closed, ignoring update');
        return;
      }

      _isUpdating = true;
      await _addState(ServiceStateUpdating._(_state.value, wasUpdating: false), false);
      var savePoint = _state.value;
      try {
        await updates(savePoint, (newSavePoint) => savePoint = newSavePoint).asyncMap((value) async {
          if (_shouldStateBeEmitted(_state.value, value)) {
            await _addState(ServiceStateUpdating._(value, wasUpdating: true));
          }
        }).last;
        await _addState(ServiceStateIdle._(_state.value));
      } catch (error, trace) {
        await _addState(ServiceStateError._(savePoint, error, trace));
        rethrow;
      } finally {
        _ignoreUpdates = false;
        _isUpdating = false;
      }
    });
  }

  Future<void> _addState(ServiceState<S> state, [bool shouldCache = true]) async {
    if (isClosed) return;
    _state = state;
    _controller.add(state);
    if (verboseLogging) {
      if (_logger.level >= Level.FINEST) {
        _logger.finest('[$name] State updated\n$state');
      } else {
        _logger.finer('[$name] State updated');
      }
    }
    final cache = _cache;
    if (cache != null && shouldCache) {
      try {
        await cache.put(state.value);
        if (verboseLogging) {
          _logger.finer('[$name] State written to cache');
        }
      } catch (err, trace) {
        _logger.severe('[$name] Failed to write to ${_cache.runtimeType}', err, trace);
      }
    }
  }

  /// Closes the service. Any in-flight update operations will be discarded and further calls to update the service
  /// state will result in errors.
  @mustCallSuper
  Future<void> close() async {
    await initComplete;
    _logger.fine('[$name] Closing');
    await _controller.close();
    await _cache?.close();
  }
}
