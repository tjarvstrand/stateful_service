// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_positioned_parameter.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

final aProvider = _$aNotifierProvider;

typedef ARef = AutoDisposeNotifierProviderRef<int>;

extension on _$ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
}

@riverpod
class _$ANotifier extends _$$ANotifier {
  int build(int a) {
    service = A(
      ref,
      a,
    );
    _subscription = service.listen((state) => state = state);
    ref.onDispose(() {
      _subscription.cancel();
      if (_closeOnDispose) {
        service.close();
      }
    });
    return service.state;
  }

  late final A service;
  late final StreamSubscription _subscription;
  final _closeOnDispose = true;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(int old, int current) => true;
}
