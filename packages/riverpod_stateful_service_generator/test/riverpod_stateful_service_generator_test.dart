import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:riverpod_stateful_service_generator/riverpod_stateful_service_generator.dart';
import 'package:riverpod_stateful_service_generator/src/riverpod_stateful_service_generator.dart';
import 'package:test/test.dart';

Map<String, String> resource(String name) =>
    {'stateful_service_generator|test/resources/$name.dart': File('test/resources/$name.dart').readAsStringSync()};

Map<String, String> output(String name) => {
      'stateful_service_generator|test/resources/$name.stateful_service.dart':
          File('test/resources/$name.stateful_service.dart').readAsStringSync()
    };

Future<void> main() async {
  group('Generators', () {
    test(
      'base',
      () async => testBuilder(
        riverpodServiceBuilder(BuilderOptions.empty),
        resource('success_base'),
        outputs: output('success_base'),
        reader: await PackageAssetReader.currentIsolate(),
      ),
    );
    test(
      'with positioned parameter',
      () async => testBuilder(
        riverpodServiceBuilder(BuilderOptions.empty),
        resource('success_with_positioned_parameter'),
        reader: await PackageAssetReader.currentIsolate(),
        outputs: output('success_with_positioned_parameter'),
      ),
    );
    test(
      'with annotation arguments',
      () async => testBuilder(
        riverpodServiceBuilder(BuilderOptions.empty),
        resource('success_with_annotation_arguments'),
        outputs: output('success_with_annotation_arguments'),
        reader: await PackageAssetReader.currentIsolate(),
      ),
    );
  });

  group('Validations', () {
    test(
      'Missing extends',
      () => expect(
        () async => testBuilder(
          riverpodServiceBuilder(BuilderOptions.empty),
          resource('fail_missing_extends'),
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(isA<MissingExtensionError>()),
      ),
    );
    test(
      'Missing build function',
      () => expect(
        () async => testBuilder(
          riverpodServiceBuilder(BuilderOptions.empty),
          resource('fail_missing_unnamed_constructor'),
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(isA<MissingUnnamedConstructorError>()),
      ),
    );
  });
}
