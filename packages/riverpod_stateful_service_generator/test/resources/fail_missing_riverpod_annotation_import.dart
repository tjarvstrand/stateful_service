import 'package:riverpod/riverpod.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

part 'fail_missing_riverpod_annotation_import.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A(Ref ref) : super(initialState: 1);
}
