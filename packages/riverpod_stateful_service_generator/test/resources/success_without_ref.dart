import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';

part 'success_without_ref.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A() : super(initialState: 1);
}
