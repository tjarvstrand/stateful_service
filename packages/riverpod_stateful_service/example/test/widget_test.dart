import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_stateful_service/riverpod_stateful_service.dart';
import 'package:stateful_service/stateful_service.dart';

class CounterService extends StatefulService<int> {
  CounterService(Ref ref) : super(initialState: 0);

  Future<void> increment() => update((state) => state + 1);
}

final StatefulServiceNotifierProvider<CounterService, int>
    counterServiceProvider = NotifierProvider.autoDispose(
        () => StatefulServiceNotifier(CounterService.new));

void main() {
  testWidgets('Service state can be updated through a WidgetRef',
      (tester) async {
    final container = ProviderContainer();
    final widget = UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Consumer(builder: (_, ref, __) {
            return Column(
              children: [
                Text(ref.watch(counterServiceProvider.value).toString()),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () =>
                        ref.read(counterServiceProvider.service).increment()),
              ],
            );
          }),
        ));

    await tester.pumpWidget(widget);

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}
