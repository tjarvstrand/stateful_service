import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';

part 'success_multiple_services.stateful_service.dart';

@riverpodService
class A extends StatefulService<int> {
  A(Ref ref) : super(initialState: 1);
}

@riverpodService
class B extends StatefulService<int> {
  B(Ref ref) : super(initialState: 1);
}
