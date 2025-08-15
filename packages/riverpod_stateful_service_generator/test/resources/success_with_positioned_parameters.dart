import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';

part 'success_with_positioned_parameters.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A(Ref ref, int a, [int? b, int c = 0]) : super(initialState: a + (b ?? 0) + c);
}
