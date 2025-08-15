// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_positioned_parameters.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = StatefulServiceNotifierProvider<A, int>;

typedef ANotifierProviderFamily = StatefulServiceNotifierProviderFamily<A, int, (int, int?, int)>;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);

  ProviderListenable<int> get value => select((s) => s.value);
}

ANotifierProvider aProvider(int a, [int? b, int c = 0]) => _$aProvider((a, b, c));

final ANotifierProviderFamily _$aProvider = NotifierProvider.autoDispose.family(
  (arg) => StatefulServiceNotifier((ref) => A(ref, arg.$1, arg.$2, arg.$3)),
);
