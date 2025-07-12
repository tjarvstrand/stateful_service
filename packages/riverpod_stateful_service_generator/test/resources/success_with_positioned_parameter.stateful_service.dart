// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_positioned_parameter.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = _$ANotifierProvider;

const aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
  ProviderListenable<int> get value => select((s) => s.value);
}

@riverpod
class _$ANotifier extends _$$ANotifier {
  late A service;

  late StreamSubscription _subscription;

  @override
  ServiceState<int> build(int a) {
    service = A(ref, a);
    _subscription = service.listen((state) => this.state = state);
    ref.onDispose(() {
      _subscription.cancel();
      service.close();
    });
    return service.state;
  }

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState<int> old, ServiceState<int> current) => true;
}
