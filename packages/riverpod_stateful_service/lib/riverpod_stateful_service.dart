import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:stateful_service/stateful_service.dart';

typedef StatefulServiceNotifierProvider<Service extends StatefulService<State>, State>
    = StateNotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>>;

typedef StatefulServiceNotifierProviderFamily<Service extends StatefulService<State>, State, Arg>
    = StateNotifierProviderFamily<StatefulServiceNotifier<Service, State>, ServiceState<State>, Arg>;

typedef AutoDisposeStatefulServiceNotifierProvider<Service extends StatefulService<State>, State>
    = AutoDisposeStateNotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>>;

typedef AutoDisposeStatefulServiceNotifierProviderFamily<Service extends StatefulService<State>, State, Arg>
    = AutoDisposeStateNotifierProviderFamily<StatefulServiceNotifier<Service, State>, ServiceState<State>, Arg>;

extension StatefulServiceNotifierProviderExt<Service extends StatefulService<State>, State>
    on StateNotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>> {
  ProviderListenable<Service> get service => notifier.select((it) => it.service);
  ProviderListenable<State> get state => select((it) => it.state);
}

extension AutoDisposeStatefulServiceNotifierProviderExt<Service extends StatefulService<State>, State>
    on AutoDisposeStateNotifierProvider<StatefulServiceNotifier<Service, State>, ServiceState<State>> {
  ProviderListenable<Service> get service => notifier.select((it) => it.service);
  ProviderListenable<State> get state => select((it) => it.state);
}

StatefulServiceNotifierProvider<Service, State> statefulServiceProvider<Service extends StatefulService<State>, State>(
  Service Function(Ref ref) f,
) =>
    StateNotifierProvider((ref) => StatefulServiceNotifier(f(ref)));

StatefulServiceNotifierProviderFamily<Service, State, Arg>
    statefulServiceProviderFamily<Service extends StatefulService<State>, State, Arg>(
  Service Function(Ref ref, Arg arg) f,
) =>
        StateNotifierProviderFamily((ref, arg) => StatefulServiceNotifier(f(ref, arg)));

AutoDisposeStatefulServiceNotifierProvider<Service, State>
    autoDisposeStatefulServiceProvider<Service extends StatefulService<State>, State>(
  Service Function(Ref ref) f,
) =>
        AutoDisposeStateNotifierProvider((ref) => StatefulServiceNotifier(f(ref)));

AutoDisposeStatefulServiceNotifierProviderFamily<Service, State, Arg>
    autoDisposeStatefulServiceProviderFamily<Service extends StatefulService<State>, State, Arg>(
  Service Function(Ref ref, Arg arg) f,
) =>
        AutoDisposeStateNotifierProviderFamily((ref, arg) => StatefulServiceNotifier(f(ref, arg)));

/// A state notifier for a [StatefulService].
///
/// Updates its state and notifies listeners whenever its [service] emits a new state.
class StatefulServiceNotifier<Service extends StatefulService<State>, State>
    extends StateNotifier<ServiceState<State>> {
  /// Creates a [StatefulServiceNotifier] with a [service].
  ///
  /// If [closeOnDispose] is true, [service] will be closed when this notifier is disposed.
  StatefulServiceNotifier(this.service, {bool closeOnDispose = true})
      : _closeOnDispose = closeOnDispose,
        super(service.serviceState) {
    _subscription = service.listen((state) {
      if (mounted) this.state = state;
    });
  }

  late StreamSubscription _subscription;

  /// A reference to this notifier's backing [StatefulService].
  final Service service;
  final bool _closeOnDispose;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState old, ServiceState current) => true;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    if (_closeOnDispose) unawaited(service.close());
    if (mounted) super.dispose();
  }
}
