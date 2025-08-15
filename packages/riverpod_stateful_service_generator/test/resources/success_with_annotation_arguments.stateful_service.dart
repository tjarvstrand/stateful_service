// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_annotation_arguments.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = StatefulServiceNotifierProvider<A, int>;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);

  ProviderListenable<int> get value => select((s) => s.value);
}

final ANotifierProvider aProvider = NotifierProvider(
  () => StatefulServiceNotifier((ref) => A(ref), closeOnDispose: true),
  name: 'aProvider',
  retry: const Duration(seconds: 1),
  dependencies: [counter, B, bla],
);
