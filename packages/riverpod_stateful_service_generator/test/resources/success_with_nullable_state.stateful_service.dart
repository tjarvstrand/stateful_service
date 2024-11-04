// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_nullable_state.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = AutoDisposeNotifierProvider<_$ANotifier, ServiceState<int?>>;

final aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
  ProviderListenable<int?> get state => select((s) => s.state);
}

@riverpod
class _$ANotifier extends _$$ANotifier {
  @override
  ServiceState<int?> build() {
    service = A(
      ref,
    );
    _subscription = service.listen((state) => this.state = state);
    ref.onDispose(() {
      _subscription.cancel();
      if (_closeOnDispose) {
        service.close();
      }
    });
    return service.serviceState;
  }

  late A service;
  late StreamSubscription _subscription;
  final _closeOnDispose = true;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState<int?> old, ServiceState<int?> current) => true;
}
