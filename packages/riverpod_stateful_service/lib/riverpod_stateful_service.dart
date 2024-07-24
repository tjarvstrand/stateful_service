import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:stateful_service/stateful_service.dart';

typedef StatefulServiceNotifierProvider<Service extends StatefulService<State>,
        State>
    = StateNotifierProvider<StatefulServiceNotifier<Service, State>, State>;

typedef AutoDisposeStatefulServiceNotifierProvider<
        Service extends StatefulService<State>, State>
    = AutoDisposeStateNotifierProvider<StatefulServiceNotifier<Service, State>,
        State>;

typedef AutoDisposeStatefulServiceNotifierProviderFamily<
        Service extends StatefulService<State>, State, Arg>
    = AutoDisposeStateNotifierProviderFamily<
        StatefulServiceNotifier<Service, State>, State, Arg>;

extension StatefulServiceNotifierProviderExt<
        Service extends StatefulService<State>, State>
    on StateNotifierProvider<StatefulServiceNotifier<Service, State>, State> {
  AlwaysAliveProviderListenable<Service> get service =>
      notifier.select((it) => it.service);
}

extension AutoDisposeStatefulServiceNotifierProviderExt<
        Service extends StatefulService<State>, State>
    on AutoDisposeStateNotifierProvider<StatefulServiceNotifier<Service, State>,
        State> {
  ProviderListenable<Service> get service =>
      notifier.select((it) => it.service);
}

/// A state notifier for a [StatefulService].
///
/// Updates its state and notifies listeners whenever its [service] emits a new state.

class StatefulServiceNotifier<Service extends StatefulService<State>, State>
    extends StateNotifier<State> {
  /// Creates a [StatefulServiceNotifier] with a [service].
  ///
  /// If [closeOnDispose] is true, [service] will be closed when this notifier is disposed.
  StatefulServiceNotifier(this.service, {bool closeOnDispose = true})
      : _closeOnDispose = closeOnDispose,
        super(service.state) {
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
  bool updateShouldNotify(State old, State current) => true;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    if (_closeOnDispose) unawaited(service.close());
    if (mounted) super.dispose();
  }
}
