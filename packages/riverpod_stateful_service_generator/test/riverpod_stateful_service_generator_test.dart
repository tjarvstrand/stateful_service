import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod_stateful_service_generator/riverpod_stateful_service_generator.dart';
import 'package:riverpod_stateful_service_generator/src/riverpod_stateful_service_generator.dart';
import 'package:test/test.dart';

String format(String code, Version version) => DartFormatter(languageVersion: version, pageWidth: 120).format(code);

final _builderOptions = BuilderOptions({'formatter': format});

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
        riverpodServiceBuilder(_builderOptions),
        resource('success_base'),
        outputs: output('success_base'),
        reader: await PackageAssetReader.currentIsolate(),
      ),
    );
    test(
      'nullable_state',
      () async => testBuilder(
        riverpodServiceBuilder(_builderOptions),
        resource('success_with_nullable_state'),
        outputs: output('success_with_nullable_state'),
        reader: await PackageAssetReader.currentIsolate(),
      ),
    );
    test(
      'with positioned parameter',
      () async => testBuilder(
        riverpodServiceBuilder(_builderOptions),
        resource('success_with_positioned_parameter'),
        reader: await PackageAssetReader.currentIsolate(),
        outputs: output('success_with_positioned_parameter'),
      ),
    );
    test(
      'with annotation arguments',
      () async => testBuilder(
        riverpodServiceBuilder(_builderOptions),
        resource('success_with_annotation_arguments'),
        outputs: output('success_with_annotation_arguments'),
        reader: await PackageAssetReader.currentIsolate(),
      ),
    );
    test(
      'with ref member variable',
      () async => testBuilder(
        riverpodServiceBuilder(_builderOptions),
        resource('success_with_ref_member'),
        outputs: output('success_with_ref_member'),
        reader: await PackageAssetReader.currentIsolate(),
      ),
    );
  });

  group('Validations', () {
    test(
      'Missing extends',
      () => expect(
        () async => testBuilder(
          riverpodServiceBuilder(_builderOptions),
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
          riverpodServiceBuilder(_builderOptions),
          resource('fail_missing_unnamed_constructor'),
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(
          allOf(
            isA<MissingUnnamedConstructorError>(),
          ),
        ),
      ),
    );
  });
}
