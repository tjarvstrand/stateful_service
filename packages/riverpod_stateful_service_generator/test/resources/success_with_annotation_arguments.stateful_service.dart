// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_annotation_arguments.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

final aProvider = _$aNotifierProvider;

typedef ARef = NotifierProviderRef<int>;

extension on _$ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
}

@Riverpod(keepAlive: true, dependencies: [counter, B, bla])
class _$ANotifier extends _$$ANotifier {
  int build() {
    service = A(
      ref,
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
  final _closeOnDispose = false;

  // Defer this decision to [service].
  @override
  bool updateShouldNotify(int old, int current) => true;
}
