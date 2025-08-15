// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_with_super_parameters.dart';

// **************************************************************************
// RiverpodStatefulServiceGenerator
// **************************************************************************

typedef ANotifierProvider = StatefulServiceNotifierProvider<A, int>;

typedef ANotifierProviderFamily = StatefulServiceNotifierProviderFamily<A, int, ({String? name, int initialState})>;

extension ANotifierProviderExt on ANotifierProvider {
  ProviderListenable<A> get service => notifier.select((n) => n.service);

  ProviderListenable<int> get value => select((s) => s.value);
}

ANotifierProvider aProvider({String? name, required int initialState}) =>
    _$aProvider((name: name, initialState: initialState));

final ANotifierProviderFamily _$aProvider = NotifierProvider.autoDispose.family(
  (arg) => StatefulServiceNotifier((ref) => A(ref, name: arg.name, initialState: arg.initialState)),
);
