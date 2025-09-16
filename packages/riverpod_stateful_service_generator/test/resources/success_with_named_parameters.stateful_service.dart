// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_named_parameters.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas

typedef ANotifierProvider = StatefulServiceNotifierProvider<A, int>;

typedef ANotifierProviderFamily = StatefulServiceNotifierProviderFamily<A, int, (int, {int b, int c, int? d})>;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);

  ProviderListenable<int> get value => select((s) => s.value);
}

ANotifierProvider aProvider(int a, {required int b, int c = 0, int? d}) => _$aProvider((a, b: b, c: c, d: d));

final ANotifierProviderFamily _$aProvider = NotifierProvider.autoDispose.family(
  (arg) => StatefulServiceNotifier((ref) => A(ref, arg.$1, b: arg.b, c: arg.c, d: arg.d)),
);
