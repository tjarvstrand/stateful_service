import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

/// Forked from build_resolvers
String assetPath(AssetId assetId) {
  return p.posix.join('/${assetId.package}', assetId.path);
}

abstract class ParserGenerator<AnnotationT> extends GeneratorForAnnotation<AnnotationT> {
  FutureOr<String> generateForUnit(Iterable<CompilationUnit> compilationUnits);

  @override
  Stream<String> generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async* {
    final asts =
        await Future.wait(element.fragments.map((fragment) => buildStep.resolver.astNodeFor(fragment, resolve: true)));

    yield await generateForUnit(asts.nonNulls.map((ast) => ast.root).whereType<CompilationUnit>());
  }
}
