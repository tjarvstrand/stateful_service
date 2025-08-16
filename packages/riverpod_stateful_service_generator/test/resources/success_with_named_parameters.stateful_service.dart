// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_named_parameters.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = _$ANotifierProvider;

const aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
  ProviderListenable<(int, int, int, int?)> get value => select((s) => s.value);
}

@riverpod
class _$ANotifier extends _$$ANotifier {
  late A service;

  late StreamSubscription _subscription;

  @override
  ServiceState<(int, int, int, int?)> build(int a, {required int b, int c = 0, int? d}) {
    service = A(ref, a, b: b, c: c, d: d);
    _subscription = service.listen((state) => this.state = state);
    ref.onDispose(() {
      _subscription.cancel();
      service.close();
    });
    return service.state;
  }

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState<(int, int, int, int?)> old, ServiceState<(int, int, int, int?)> current) => true;
}
