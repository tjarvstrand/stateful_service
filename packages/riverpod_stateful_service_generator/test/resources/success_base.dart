import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';

part 'success_base.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A(Ref ref) : super(initialState: 1);
}
