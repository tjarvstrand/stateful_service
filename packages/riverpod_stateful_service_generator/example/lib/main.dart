import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';

part 'main.stateful_service.dart';

void main() => runApp(ProviderScope(child: const MyApp()));

@RiverpodService(keepAlive: true)
class CounterService extends StatefulService<int> {
  CounterService(Ref ref, String name) : super(initialState: 0, name: name);

  Future<void> increment() => update((state) => state + 1);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Stateful Service Riverpod Generator Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('Stateful Service Riverpod Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text('${ref.watch(counterServiceProvider('my button').value)}',
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ref.read(counterServiceProvider('my button').service).increment(),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
