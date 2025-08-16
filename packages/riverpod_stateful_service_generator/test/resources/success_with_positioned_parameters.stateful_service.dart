// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_positioned_parameters.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = _$ANotifierProvider;

const aProvider = _$aNotifierProvider;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);
  ProviderListenable<(int, int?, int)> get value => select((s) => s.value);
}

@riverpod
class _$ANotifier extends _$$ANotifier with StatefulServiceNotifierMixin<A, (int, int?, int)> {
  late A _service;

  @override
  final closeOnDispose = true;

  @override
  ServiceState<(int, int?, int)> build(int a, [int? b, int c = 0]) {
    _service = A(ref, a, b, c);
    return _service.state;
  }
}
