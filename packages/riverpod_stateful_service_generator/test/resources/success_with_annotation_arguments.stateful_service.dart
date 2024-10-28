// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_annotation_arguments.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ARef = NotifierProviderRef<int>;
typedef ANotifierProvider = NotifierProvider<_$ANotifier, int>;

final aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
}

@Riverpod(keepAlive: true, dependencies: [counter, B, bla])
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
  final _closeOnDispose = false;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(int old, int current) => true;
}
