import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_stateful_service/riverpod_stateful_service.dart';
import 'package:stateful_service/stateful_service.dart';

void main() => runApp(ProviderScope(child: const MyApp()));

class CounterService extends StatefulService<int> {
  CounterService(Ref ref, {super.name = 'default'}) : super(initialState: 0);

  Future<void> increment() => update((state) => state + 1);
}

final StatefulServiceNotifierProviderFamily<CounterService, int, String>
    counterServiceProvider = NotifierProvider.autoDispose.family((name) =>
        StatefulServiceNotifier((ref) => CounterService(ref, name: name)));

final class MyApp extends ConsumerWidget {
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
          onPressed: () =>
              ref.read(counterServiceProvider('my button').service).increment(),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
