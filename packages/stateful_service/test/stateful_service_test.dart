import 'dart:async';

import 'package:logging/logging.dart';
import 'package:stateful_service/stateful_service.dart';
import 'package:test/test.dart';

class TestService extends StatefulService<int> {
  TestService({required super.initialState, super.init, super.cache, super.logger});
}

class TestCache with StatefulServiceCache<int> {
  TestCache(this.value);

  int? value;

  @override
  Future<int?> init() => Future.value(value);

  @override
  Future<void> close() => Future.value();

  @override
  Future<void> put(int state) async {
    if (state < 0) throw ArgumentError();
    value = state;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  Logger.root.level = Level.OFF;

  late TestService service;

  group('StatefulService', () {
    group('initialization', () {
      test('sets isInitializing when done', () async {
        final service = TestService(initialState: 0, init: (_) => Future.delayed(const Duration(milliseconds: 300)));
        expect(service.isInitializing, true);
        await service.initComplete;
        expect(service.isInitializing, false);
      });
    });
    group('update', () {
      setUp(() => service = TestService(initialState: 0));
      tearDown(() => service.close());
      test('updates the service state with single values', () async {
        await service.update((state) => state + 1);
        expect(service.state.value, 1);
        await service.update((state) => state + 1);
        expect(service.state.value, 2);
        await service.close();
      });
      test('keeps the state when an update fails', () async {
        await service.update((state) => state + 1);
        await service.update((_) => Future.error(Exception('Failed'))).onError((_, __) => null);
        expect(service.state.value, 1);
      });
      test('Drops concurrent updates if ignoreConcurrentRequests is true', () async {
        final update1Started = Completer();
        final update1CanComplete = Completer();
        final update1 = service.update((_) async {
          update1Started.complete();
          await update1CanComplete.future;
          return 1;
        }, ignoreConcurrentUpdates: true);
        await update1Started.future;
        final update2 = service.update((_) => 2);
        update1CanComplete.complete();
        await update1;
        await update2;
        expect(service.state.value, 1);
        await service.close();
      });
      test('Fails if the service is closed', () async {
        await service.close();
        expect(() => service.update((state) => state), throwsStateError);
      });
    });
    group('streamUpdates', () {
      setUp(() => service = TestService(initialState: 0));
      tearDown(() => service.close());
      test('updates the service state', () async {
        await service.initComplete;
        final values = service.values.take(4).toList();
        await service.streamUpdates((state, _) async* {
          yield state + 1;
          yield state + 2;
        });
        await service.streamUpdates((state, _) async* {
          yield state + 1;
          yield state + 2;
        });
        expect(await values, [1, 2, 3, 4]);
      });
      test('Emits ServiceStateUpdating', () async {
        await service.initComplete;
        final values = service.states.take(3).toList();
        await service.streamUpdates((state, _) async* {
          yield state + 1;
        });
        expect((await values)[0], isA<ServiceStateUpdating>());
        expect((await values)[1], isA<ServiceStateUpdating>());
        expect((await values)[2], isA<ServiceStateIdle>());
      });
      test('Rolls back the state when an update fails', () async {
        final values = service.values.take(2).toList();
        await service.streamUpdates((state, _) async* {
          yield state + 1;
          throw Exception('Failed');
        }).onError((_, __) {});
        expect(await values, [1, 0]);
      }, timeout: Timeout(Duration(seconds: 1)));
      test('Rolls back the state to the last save point when an update fails', () async {
        final values = service.values.take(3).toList();
        await service.streamUpdates((state, save) async* {
          yield state + 1;
          save(state + 1);
          yield state + 2;
          throw Exception('Failed');
        }).onError((_, __) {});
        expect(await values, [1, 2, 1]);
      });
      test('Drops concurrent updates if ignoreConcurrentRequests is true', () async {
        final update1Started = Completer();
        final update1CanComplete = Completer();
        final update1 = service.streamUpdates((_, __) async* {
          update1Started.complete();
          await update1CanComplete.future;
          yield 2;
        }, ignoreConcurrentUpdates: true);
        await update1Started.future;
        final update2 = service.streamUpdates((_, __) => Stream.value(3));
        update1CanComplete.complete();
        await update1;
        await update2;
        expect(service.state.value, 2);
      });
      test('Fails if the service is closed', () async {
        await service.close();
        expect(() => service.streamUpdates((_, __) => const Stream.empty()), throwsStateError);
      });
    });
    group('cache', () {
      final cache = TestCache(null);
      late TestService service;
      tearDown(() => service.close());
      test('is initialized and read when initializing the service', () async {
        cache.value = 1;
        service = TestService(initialState: 0, cache: cache);
        await service.initComplete;
        expect(service.state.value, 1);
      });
      test('is updated if empty when initializing the service', () async {
        cache.value = null;
        service = TestService(initialState: 0, cache: cache);
        await service.initComplete;
        expect(service.state.value, 0);
      });
      test('is updated when updating the service state', () async {
        cache.value = 1;
        service = TestService(initialState: 0, cache: cache);
        await service.initComplete;
        await service.update((state) => 2);
        expect(service.state.value, 2);
      });
      test('can be cleared by the service', () async {
        cache.value = null;
        service = TestService(initialState: 0, cache: cache);
        await service.initComplete;
        expect(cache.value, 0);
        await service.clearCache();
        expect(cache.value, null);
      });
      test('does not prevent service from updating its state when cache write fails', () async {
        cache.value = 1;
        service = TestService(initialState: 0, cache: cache);
        await service.initComplete;
        await service.update((state) => -2);
        expect(cache.value, 1);
        expect(service.state.value, -2);
      });
    });
  });
}
