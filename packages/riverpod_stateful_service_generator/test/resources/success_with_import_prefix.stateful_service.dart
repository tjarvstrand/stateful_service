// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_import_prefix.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas

typedef ANotifierProvider = s.StatefulServiceNotifierProvider<A, c.int>;

typedef ANotifierProviderFamily = s.StatefulServiceNotifierProviderFamily<A, c.int, (c.int, c.int)>;

extension ANotifierProviderExt on ANotifierProvider {
  s.ProviderListenable<A> get service => notifier.select((n) => n.service);

  s.ProviderListenable<c.int> get value => select((s) => s.value);
}

ANotifierProvider aProvider(c.int a, [c.int b = 0]) => _$aProvider((a, b));

final ANotifierProviderFamily _$aProvider = s.NotifierProvider.autoDispose.family(
  (arg) => s.StatefulServiceNotifier((ref) => A(ref, arg.$1, arg.$2)),
);
