import 'dart:core' as c;

import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart' as s;

part 'success_with_import_prefix.stateful_service.dart';

@s.riverpodService
class A extends s.StatefulService<c.int> {
  A(s.Ref ref, c.int a, [c.int b = 0]) : super(initialState: a + b);
}
