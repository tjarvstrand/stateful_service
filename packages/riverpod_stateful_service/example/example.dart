import 'package:riverpod_stateful_service/riverpod_stateful_service.dart';
import 'package:stateful_service/stateful_service.dart';

class User {
  const User({required this.name});

  final String name;
}

class UserService extends StatefulService<User> {
  UserService({required super.initialState});

  /// Your code here...
}

final StatefulServiceNotifierProvider<UserService, User> userServiceProvider = StatefulServiceNotifierProvider((ref) {
  return StatefulServiceNotifier(UserService(initialState: const User(name: 'John Doe')));
});
