import 'dart:io';

import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod_stateful_service_generator/riverpod_stateful_service_generator.dart';
import 'package:test/test.dart';

String format(String code, Version version) => DartFormatter(languageVersion: version, pageWidth: 120).format(code);

final _builderOptions = BuilderOptions({'formatter': format});

Map<String, String> resource(String name) =>
    {'stateful_service_generator|test/resources/$name.dart': File('test/resources/$name.dart').readAsStringSync()};

Map<String, String> output(String name) => {
      'stateful_service_generator|test/resources/$name.stateful_service.dart':
          File('test/resources/$name.stateful_service.dart').readAsStringSync()
    };

Future<TestBuilderResult> _runTest(String name, {bool succeeds = true}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'riverpod_stateful_service_generator');
  await readerWriter.testing.loadIsolateSources();
  return testBuilder(
    riverpodServiceBuilder(_builderOptions),
    resource(name),
    outputs: succeeds ? output(name) : null,
    readerWriter: readerWriter,
  );
}

Future<void> main() async {
  group('Generators', () {
    test('base', () => _runTest('success_base'));
    test('nullable_state', () => _runTest('success_with_nullable_state'));
    test('with positioned parameter', () => _runTest('success_with_positioned_parameter'));
    test('with annotation arguments', () => _runTest('success_with_annotation_arguments'));
    test('with ref member variable', () => _runTest('success_with_ref_member'));
  });

  // Can't detect the specific failure reasons anymore, so we just check that the build fails.
  group('Validations', () {
    test(
      'Missing extends',
      () => expect(
        _runTest('fail_missing_extends', succeeds: false),
        // Can't detect the specific failure reasons anymore, so we just check that the build fails.
        completion(isA<TestBuilderResult>().having((r) => r.buildResult.status, 'status', BuildStatus.failure)),
      ),
    );
    test(
      'Missing build function',
      () => expect(
        _runTest('fail_missing_unnamed_constructor', succeeds: false),
        // Can't detect the specific failure reasons anymore, so we just check that the build fails.
        completion(isA<TestBuilderResult>().having((r) => r.buildResult.status, 'status', BuildStatus.failure)),
      ),
    );
  });
}
