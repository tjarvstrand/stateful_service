[![pub package](https://img.shields.io/pub/v/riverpod_stateful_service.svg?label=riverpod_stateful_service&color=blue)](https://pub.dev/packages/riverpod_stateful_service)
[![popularity](https://img.shields.io/pub/popularity/riverpod_stateful_service?logo=dart)](https://pub.dev/packages/riverpod_stateful_service/score)
[![likes](https://img.shields.io/pub/likes/riverpod_stateful_service?logo=dart)](https://pub.dev/packages/riverpod_stateful_service/score)
[![pub points](https://img.shields.io/pub/points/riverpod_stateful_service?logo=dart)](https://pub.dev/packages/riverpod_stateful_service/score)
![building](https://github.com/jonataslaw/get/workflows/build/badge.svg)


Lightweight [stateful_service](https://pub.dev/packages/stateful_service) wrapper for [riverpod](https://pub.dev/packages/riverpod).

## Getting started

See the `stateful_service` package documentation for more information on how to get started.

Once you have a `StatefulService`, you can easily create a Riverpod notifier provider for it:

```dart
class UserService extends StatefulService<User> {
  ...
}

final StatefulServiceNotifierProvider<UserService, User> userProvider = StatefulServiceNotifierProvider((ref) {
  return StatefulServiceNotifier(UserService(initialState: const User(name: 'John Doe')));
});
```

You can then use the provider as you would any other Riverpod provider:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider);
  ...
}
```

You can also access the service directly using the included `Provider` extension, e.g:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final userService = ref.watch(userProvider.service);
  ...
}
```
