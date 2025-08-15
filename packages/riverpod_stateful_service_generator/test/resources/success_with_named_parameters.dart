import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';

part 'success_with_named_parameters.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A(Ref ref, int a, {required int b, int c = 0, int? d}) : super(initialState: a + b + c + (d ?? 0));
}
