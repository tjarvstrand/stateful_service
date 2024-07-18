import 'package:shared_preferences_stateful_service_cache/shared_preferences_stateful_service_cache.dart';
import 'package:stateful_service/stateful_service.dart';

class User {
  const User({required this.name});

  final String name;
}

class UserService extends StatefulService<User> {
  UserService({required super.initialState})
      : super(
          cache: SharedPreferencesStatefulServiceCache(
            key: 'userServiceState',
            encode: (user) => user.name,
            decode: (name) => User(name: name),
          ),
        );

  /// Your code here...
}
