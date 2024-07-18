
`[shared_preferences](https://pub.dev/packages/shared_preferences)`-based cache implementation for `[stateful_service](https://pub.dev/packages/stateful_service)`.

## Getting started

See the `stateful_service` package documentation for more information on how to get started.

Once you have a `StatefulService`, you can use `SharedPreferencesStatefulServiceCache` to cache the 
service's state using `SharedPreferences`.

```dart
class UserService extends StatefulService<User> {
  UserService({required super.initialState})
      : super(
    cache: SharedPreferencesStatefulServiceCache(
      key: 'userServiceState',
      encode: (user) => user.name,
      decode: (name) => User(name: name),
    ),
  );

  ...
}
```

