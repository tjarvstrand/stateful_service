import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

@riverpodService
class FailMissingBuildFunction extends StatefulService<int> {
  FailMissingBuildFunction.create({required super.initialState});
}
