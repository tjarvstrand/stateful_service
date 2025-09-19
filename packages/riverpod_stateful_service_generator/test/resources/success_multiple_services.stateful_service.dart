// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_multiple_services.dart';

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

typedef BNotifierProvider = StatefulServiceNotifierProvider<B, int>;

extension BNotifierProviderExt on BNotifierProvider {
  ProviderListenable<B> get service => notifier.select((n) => n.service);

  ProviderListenable<int> get value => select((s) => s.value);
}

final BNotifierProvider bProvider = NotifierProvider.autoDispose(() => StatefulServiceNotifier((ref) => B(ref)));
