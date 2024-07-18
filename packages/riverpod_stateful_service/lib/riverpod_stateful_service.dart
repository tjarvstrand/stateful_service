import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:stateful_service/stateful_service.dart';

typedef StatefulServiceNotifierProvider<Service extends StatefulService<State>, State>
    = StateNotifierProvider<StatefulServiceNotifier<Service, State>, State>;

typedef AutoDisposeStatefulServiceNotifierProvider<Service extends StatefulService<State>, State>
    = AutoDisposeStateNotifierProvider<StatefulServiceNotifier<Service, State>, State>;

typedef AutoDisposeStatefulServiceNotifierProviderFamily<Service extends StatefulService<State>, State, Arg>
    = AutoDisposeStateNotifierProviderFamily<StatefulServiceNotifier<Service, State>, State, Arg>;

extension StatefulServiceNotifierProviderExt<Service extends StatefulService<State>, State>
    on StateNotifierProvider<StatefulServiceNotifier<Service, State>, State> {
  AlwaysAliveProviderListenable<Service> get service => notifier.select((it) => it.service);
}

extension AutoDisposeStatefulServiceNotifierProviderExt<Service extends StatefulService<State>, State>
    on AutoDisposeStateNotifierProvider<StatefulServiceNotifier<Service, State>, State> {
  ProviderListenable<Service> get service => notifier.select((it) => it.service);
}

class StatefulServiceNotifier<Service extends StatefulService<State>, State> extends StateNotifier<State> {
  StatefulServiceNotifier(this.service, [this.closeOnDispose = true]) : super(service.state) {
    _subscription = service.listen((state) {
      if (mounted) this.state = state;
    });
  }

  late StreamSubscription _subscription;
  final Service service;
  final bool closeOnDispose;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    if (closeOnDispose) unawaited(service.close());
    if (mounted) super.dispose();
  }
}
