[![pub package](https://img.shields.io/pub/v/riverpod_stateful_service_generator.svg?label=riverpod_stateful_service_generator&color=blue)](https://pub.dev/packages/riverpod_stateful_service_generator)
[![popularity](https://img.shields.io/pub/popularity/riverpod_stateful_service_generator?logo=dart)](https://pub.dev/packages/riverpod_stateful_service_generator/score)
[![likes](https://img.shields.io/pub/likes/riverpod_stateful_service_generator?logo=dart)](https://pub.dev/packages/riverpod_stateful_service_generator/score)
[![pub points](https://img.shields.io/pub/points/riverpod_stateful_service_generator?logo=dart)](https://pub.dev/packages/riverpod_stateful_service_generator/score)
![building](https://github.com/jonataslaw/get/workflows/build/badge.svg)

## Getting started

This package provides a riverpod code generator for the `stateful_service` package, which allows you 
to easily create Riverpod providers for your `StatefulService` instances.

See the `stateful_service` package documentation for more information on how to get started.

Once you have a `StatefulService`, you can easily create a Riverpod notifier provider for it using 
an annotation:

```dart
part 'user_service.g.dart';
part 'user_service.stateful_service.dart';

@riverpodService
class UserService extends StatefulService<User> {
  ...
}
```

You can then use the provider as you would any other Riverpod provider:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userServiceProvider);
  ...
}
```

You can also access the service directly using the included `Provider` extension, e.g:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final userService = ref.watch(userServiceProvider.service);
  ...
}
```
