import 'package:stateful_service/stateful_service.dart';

class User {
  const User({required this.name});

  final String name;

  User withName(String newName) => User(name: newName);
}

class UserApi {
  Future<void> updateName(String newName) async => throw UnimplementedError();
}

class UserService extends StatefulService<User> {
  UserService({required super.initialState});

  final UserApi _api = UserApi();

  /// Updates the user's name.
  Future<void> updateName(String newName) => update((user) async {
        await _api.updateName(newName);
        return user.withName(newName);
      });

  /// Updates the user's name, updating the UI optimistically.
  Future<void> updateNameOptimistic(String newName) => streamUpdates((user) async* {
        yield user.withName(newName);
        await _api.updateName(newName);
      });
}
