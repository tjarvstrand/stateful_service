import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

/// Forked from build_resolvers
String assetPath(AssetId assetId) {
  return p.posix.join('/${assetId.package}', assetId.path);
}

abstract class ParserGenerator<AnnotationT> extends GeneratorForAnnotation<AnnotationT> {
  FutureOr<String> generateForUnit(List<CompilationUnit> compilationUnits);

  @override
  Stream<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async* {
    final ast = await buildStep.resolver.astNodeFor(element, resolve: true).then((value) => value?.root);
    ast as CompilationUnit?;
    if (ast == null) return;

    yield await generateForUnit([ast]);
  }
}
