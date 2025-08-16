[![pub package](https://img.shields.io/pub/v/shared_preferences_stateful_service_cache.svg?label=shared_preferences_stateful_service_cache&color=blue)](https://pub.dev/packages/shared_preferences_stateful_service_cache)
[![likes](https://img.shields.io/pub/likes/shared_preferences_stateful_service_cache?logo=dart)](https://pub.dev/packages/shared_preferences_stateful_service_cache/score)
[![pub points](https://img.shields.io/pub/points/shared_preferences_stateful_service_cache?logo=dart)](https://pub.dev/packages/shared_preferences_stateful_service_cache/score)
![building](https://github.com/tjarvstrand/stateful_service/workflows/stateful_service/badge.svg)


[shared_preferences](https://pub.dev/packages/shared_preferences)-based cache implementation for [stateful_service](https://pub.dev/packages/stateful_service).

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
