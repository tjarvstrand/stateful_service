
Lightweight `[stateful_service](https://pub.dev/packages/stateful_service)` wrapper for `[riverpod](https://pub.dev/packages/riverpod)`.

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

You can also access the service directly using the included `Provider` extension, e.g:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final userService = ref.watch(userProvider.service);
  ...
}
```
