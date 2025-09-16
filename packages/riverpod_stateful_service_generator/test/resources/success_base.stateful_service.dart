// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_base.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas

typedef ANotifierProvider = StatefulServiceNotifierProvider<A, int>;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);

  ProviderListenable<int> get value => select((s) => s.value);
}

final ANotifierProvider aProvider = NotifierProvider.autoDispose(() => StatefulServiceNotifier((ref) => A(ref)));
