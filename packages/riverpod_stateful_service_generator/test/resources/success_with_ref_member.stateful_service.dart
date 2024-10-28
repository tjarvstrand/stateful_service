// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_ref_member.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ARef = AutoDisposeNotifierProviderRef<int>;
typedef ANotifierProvider = AutoDisposeNotifierProvider<_$ANotifier, int>;

final aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
}

@riverpod
class _$ANotifier extends _$$ANotifier {
  @override
  int build() {
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
    return service.state;
  }

  late A service;
  late StreamSubscription _subscription;
  final _closeOnDispose = true;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(int old, int current) => true;
}
