[![pub package](https://img.shields.io/pub/v/shared_preferences_stateful_service_cache.svg?label=shared_preferences_stateful_service_cache&color=blue)](https://pub.dev/packages/shared_preferences_stateful_service_cache)
[![popularity](https://img.shields.io/pub/popularity/shared_preferences_stateful_service_cache?logo=dart)](https://pub.dev/packages/shared_preferences_stateful_service_cache/score)
[![likes](https://img.shields.io/pub/likes/shared_preferences_stateful_service_cache?logo=dart)](https://pub.dev/packages/shared_preferences_stateful_service_cache/score)
[![pub points](https://img.shields.io/pub/points/shared_preferences_stateful_service_cache?logo=dart)](https://pub.dev/packages/shared_preferences_stateful_service_cache/score)
![building](https://github.com/jonataslaw/get/workflows/build/badge.svg)


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

### Caveats

Since shared_preferences keeps all its data in memory, it's not recommended to use this cache for
services with large states. In such cases, consider using a different cache implementation.

