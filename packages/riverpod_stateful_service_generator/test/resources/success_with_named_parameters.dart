import 'package:riverpod/riverpod.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

part 'success_with_named_parameters.stateful_service.dart';

@riverpodService
class A extends StatefulService<(int, int, int, int?)> {
  A(Ref ref, int a, {required int b, int c = 0, int? d}) : super(initialState: (a, b, c, d)) {
    ;
  }
}
