import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stateful_service/stateful_service.dart';

typedef StatefulServiceNotifierProvider<Service extends StatefulService<State>, State>
    = NotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>>;

typedef StatefulServiceNotifierProviderFamily<Service extends StatefulService<State>, State, Arg>
    = NotifierProviderFamily<StatefulServiceNotifierFamily<Service, State, Arg>, ServiceState<State>, Arg>;

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

StatefulServiceNotifierProviderFamily<Service, State, Arg>
    statefulServiceProviderFamily<Service extends StatefulService<State>, State, Arg>(
  Service Function(Ref ref, Arg arg) f,
  Arg arg, {
  bool closeOnDispose = true,
  String? name,
  Iterable<ProviderOrFamily>? dependencies,
  bool isAutoDispose = false,
  Duration? Function(int retryCount, Object error)? retry,
}) =>
        NotifierProvider.family(
          () => StatefulServiceNotifierFamily(f, closeOnDispose: closeOnDispose),
          name: name,
          dependencies: dependencies,
          isAutoDispose: isAutoDispose,
          retry: retry,
        );

mixin StatefulServiceNotifierMixin<Service extends StatefulService<State>, State>
    on AnyNotifier<ServiceState<State>, ServiceState<State>> {
  late Service _service;
  bool get closeOnDispose;

  /// A reference to this notifier's backing [StatefulService].
  Service get service => _service;

  @override
  void runBuild() {
    _service = service;
    super.runBuild();
    final subscription = service.listen((state) {
      if (ref.mounted) this.state = state;
    });
    ref.onDispose(() {
      unawaited(subscription.cancel());
      if (closeOnDispose) unawaited(service.close());
    });
  }

  void init(Service service, bool closeOnDispose) {}

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
  ///
  /// If [closeOnDispose] is true, [service] will be closed when this notifier is disposed.
  StatefulServiceNotifier(this._createService, {this.closeOnDispose = true});

  final Service Function(Ref ref) _createService;

  @override
  final bool closeOnDispose;

  @override
  ServiceState<State> build() {
    _service = _createService(ref);
    return _service.state;
  }
}

/// A family notifier for a [StatefulService].
///
/// Updates its state and notifies listeners whenever its [service] emits a new state.
class StatefulServiceNotifierFamily<Service extends StatefulService<State>, State, Arg>
    extends FamilyNotifier<ServiceState<State>, Arg> with StatefulServiceNotifierMixin<Service, State> {
  /// Creates a [StatefulServiceNotifier] with a [service].
  ///
  /// If [closeOnDispose] is true, [service] will be closed when this notifier is disposed.
  StatefulServiceNotifierFamily(this._createService, {this.closeOnDispose = true});

  final Service Function(Ref ref, Arg arg) _createService;

  @override
  final bool closeOnDispose;

  @override
  ServiceState<State> build(Arg arg) {
    _service = _createService(ref, arg);
    return _service.state;
  }
}
