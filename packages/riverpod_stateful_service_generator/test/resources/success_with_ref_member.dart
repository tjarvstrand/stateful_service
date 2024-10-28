import 'package:riverpod/riverpod.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

part 'success_with_ref_member.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A(this.ref) : super(initialState: 1);

  final Ref ref;
}
