import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

part 'example.g.dart';
part 'example.stateful_service.dart';

@riverpod
int start(StartRef ref) => 0;

@RiverpodService(keepAlive: true)
class UserService extends StatefulService<int> {
  UserService(UserServiceRef ref, int v) : super(initialState: 1);
}

final a = Provider((ref) => ref.read(userServiceProvider(1).service));
