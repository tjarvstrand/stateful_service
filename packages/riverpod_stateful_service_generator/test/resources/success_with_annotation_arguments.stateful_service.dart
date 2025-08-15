// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_annotation_arguments.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = _$ANotifierProvider;

const aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
  ProviderListenable<int> get value => select((s) => s.value);
}

@Riverpod(keepAlive: true, dependencies: [counter, B, bla])
class _$ANotifier extends _$$ANotifier with StatefulServiceNotifierMixin<A, int> {
  late A _service;

  @override
  final closeOnDispose = false;

  @override
  ServiceState<int> build() {
    _service = A(ref);
    return _service.state;
  }
}
