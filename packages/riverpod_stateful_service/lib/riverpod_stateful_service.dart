import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stateful_service/stateful_service.dart';

typedef StatefulServiceNotifierProvider<Service extends StatefulService<State>, State>
    = NotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>>;

typedef StatefulServiceNotifierProviderFamily<Service extends StatefulService<State>, State, Arg>
    = NotifierProviderFamily<StatefulServiceNotifier<Service, State>, ServiceState<State>, Arg>;

typedef StatefulServiceAutoDisposeNotifierProviderFamily<Service extends StatefulService<State>, State, Arg>
    = NotifierProviderFamily<StatefulServiceNotifier<Service, State>, ServiceState<State>, Arg>;

extension StatefulServiceNotifierProviderExt<Service extends StatefulService<State>, State>
    on NotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>> {
  ProviderListenable<Service> get service => notifier.select((it) => it.service);
  ProviderListenable<State> get value => select((it) => it.value);
}

extension ServiceStateExt<T> on ServiceState<T> {
  AsyncValue<T> get asAsyncValue => when(
        idle: (state) => AsyncValue.data(state.value),
        updating: (_) => AsyncValue.loading(),
        error: (state) => AsyncValue.error(state.error, state.stackTrace),
      );
}

StatefulServiceNotifierProvider<Service, State> statefulServiceProvider<Service extends StatefulService<State>, State>(
  Service Function(Ref ref) f, {
  bool closeOnDispose = true,
  String? name,
  Iterable<ProviderOrFamily>? dependencies,
  bool isAutoDispose = false,
  Duration? Function(int retryCount, Object error)? retry,
}) =>
    NotifierProvider(
      () => StatefulServiceNotifier(f, closeOnDispose: closeOnDispose),
      name: name,
      dependencies: dependencies,
      isAutoDispose: isAutoDispose,
      retry: retry,
    );

mixin StatefulServiceNotifierMixin<Service extends StatefulService<State>, State>
    on AnyNotifier<ServiceState<State>, ServiceState<State>> {
  /// Use with care!
  ///
  /// Whether to close [service] when this notifier is disposed.
  ///
  /// If this is false, the caller is responsible for closing [service] once it is no longer needed. It also means that
  /// the service will be reused across rebuilds of this notifier, but NOT when Riverpod decides that the notifier
  /// must be recreated so you could potentially end up with multiple instances of the same service.
  bool get closeOnDispose;

  Service Function(Ref ref) get factory;

  Service? _service;

  @protected
  Service init() => _service ??= factory(ref);

  /// A reference to this notifier's backing [StatefulService].
  Service get service => _service ?? (throw StateError('Service not initialized'));

  @override
  void runBuild() {
    super.runBuild();
    final subscription = service.listen((state) {
      if (ref.mounted) this.state = state;
    });
    ref.onDispose(() {
      unawaited(subscription.cancel());
      if (closeOnDispose) {
        unawaited(_service?.close());
        _service = null;
      }
    });
  }

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState previous, ServiceState next) => true;
}

/// A notifier for a [StatefulService].
///
/// Updates its state and notifies listeners whenever its [service] emits a new state.
class StatefulServiceNotifier<Service extends StatefulService<State>, State> extends Notifier<ServiceState<State>>
    with StatefulServiceNotifierMixin<Service, State> {
  /// Creates a [StatefulServiceNotifier] with a [service].
  StatefulServiceNotifier(this.factory, {this.closeOnDispose = true});

  @override
  final Service Function(Ref ref) factory;

  /// Use with care!
  ///
  /// Whether to close [service] when this notifier is disposed.
  ///
  /// See [StatefulServiceNotifierMixin.closeOnDispose].
  @override
  final bool closeOnDispose;

  @override
  ServiceState<State> build() => init().state;
}
