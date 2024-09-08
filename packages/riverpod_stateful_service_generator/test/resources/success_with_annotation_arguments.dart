import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

part 'success_with_annotation_arguments.stateful_service.dart';

@riverpod
int counter(int i) => i;

@riverpod
class B {
  int build() => 0;
}

@riverpod
const int bla = 0;

@RiverpodService(keepAlive: true, closeOnDispose: false, dependencies: [
  counter,
  B,
  bla,
])
class A extends StatefulService<int> {
  A(ARef ref) : super(initialState: 1);
}
