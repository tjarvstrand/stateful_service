// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_annotation_arguments.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = NotifierProvider<_$ANotifier, ServiceState<int>>;

final aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
  ProviderListenable<int> get state => select((s) => s.state);
}

@Riverpod(keepAlive: true, dependencies: [counter, B, bla])
class _$ANotifier extends _$$ANotifier {
  @override
  ServiceState<int> build() {
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
  final _closeOnDispose = false;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState<int> old, ServiceState<int> current) => true;
}
