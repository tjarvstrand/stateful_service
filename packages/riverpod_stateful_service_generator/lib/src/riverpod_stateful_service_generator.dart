import 'package:analyzer/dart/ast/ast.dart' hide Block, Expression;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'parser_generator.dart';

final emitter = DartEmitter(useNullSafetySyntax: true, orderDirectives: true);

final formatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
  trailingCommas: TrailingCommas.automate,
  pageWidth: 120,
);

class MissingExtensionError extends InvalidGenerationSourceError {
  MissingExtensionError(String name, {super.todo = '', super.element})
      : super('The class $name must extend StatefulService');
}

class MissingUnnamedConstructorError extends InvalidGenerationSourceError {
  MissingUnnamedConstructorError(String name, {super.todo = '', super.element})
      : super('The class $name must declare an unnamed constructor');
}

@immutable
class RiverpodStatefulServiceGenerator extends ParserGenerator<RiverpodService> {
  @override
  String generateForUnit(List<CompilationUnit> compilationUnits) {
    final buffer = StringBuffer();
    var hasRiverPodImport = false;
    var hasRiverPodAnnotationImport = false;
    for (final unit in compilationUnits) {
      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          if (directive.uri.stringValue == 'package:riverpod/riverpod.dart') {
            hasRiverPodImport = true;
          } else if (directive.uri.stringValue == 'package:riverpod_annotation/riverpod_annotation.dart') {
            hasRiverPodAnnotationImport = true;
          }
        }
      }

      final fileName = unit.declaredElement!.source.fullName;
      if (!hasRiverPodImport) {
        log.severe('The file $fileName must import riverpod.dart');
      }

      if (!hasRiverPodAnnotationImport) {
        log.severe('The file $fileName must import riverpod_annotation.dart');
      }

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          _generateForClass(declaration, buffer);
        }
      }
    }
    return buffer.toString();
  }

  void _generateForClass(ClassDeclaration unit, StringBuffer buffer) {
    final annotation = unit.sortedCommentAndAnnotations.firstWhereOrNull(
      (node) => node is Annotation && (node.name.name == 'riverpodService' || node.name.name == 'RiverpodService'),
    ) as Annotation?;

    if (annotation == null) {
      return;
    }

    final serviceClass = unit.declaredElement;
    if (serviceClass == null) {
      return;
    }

    final statefulServiceSupertype =
        serviceClass.allSupertypes.firstWhereOrNull((supertype) => supertype.element.name == 'StatefulService');

    if (statefulServiceSupertype == null) {
      throw MissingExtensionError(serviceClass.name);
    }

    final annotationArguments = annotation.arguments?.arguments
        .where((arg) => arg is NamedExpression && arg.name.label.name != 'closeOnDispose')
        .map((arg) => arg.toString())
        .join(', ');
    final annotationOut = annotationArguments == null ? 'riverpod' : 'Riverpod(${annotationArguments})';

    final constructor = serviceClass.children.firstWhereOrNull((element) {
      return element is ConstructorElement && element.name.isEmpty;
    }) as ConstructorElement?;

    if (constructor == null) {
      throw MissingUnnamedConstructorError(serviceClass.name);
    }

    final keepAlive = annotation.arguments?.arguments
        .firstWhereOrNull((arg) => arg is NamedExpression && arg.name.label.name == 'keepAlive') as NamedExpression?;

    final isFamily = constructor.parameters.length > 1;
    final isAutoDispose = keepAlive?.expression.toString() != 'true';

    final closeOnDisposeExpr = annotation.arguments?.arguments
            .firstWhereOrNull((arg) => arg is NamedExpression && arg.name.label.name == 'closeOnDispose')
        as NamedExpression?;
    final closeOnDispose = closeOnDisposeExpr?.expression.toString() != 'false';

    final serviceType = serviceClass.name;
    final stateType = statefulServiceSupertype.typeArguments.first.getDisplayString();
    final serviceNameLower = '${serviceType.substring(0, 1).toLowerCase()}${serviceClass.name.substring(1)}';

    final providerTypeDef = TypeDef((b) => b
      ..name = '${serviceType}NotifierProvider'
      ..definition = TypeReference((b) => b
        ..symbol = isFamily
            ? '_\$${serviceType}NotifierProvider'
            : isAutoDispose
                ? 'AutoDisposeNotifierProvider'
                : 'NotifierProvider'
        ..types = ListBuilder(isFamily
            ? []
            : [
                TypeReference((b) => b..symbol = '_\$${serviceType}Notifier'),
                TypeReference((b) => b..symbol = 'ServiceState<$stateType>')
              ])));

    final providerDeclaration = Field(
      (f) => f
        ..name = '${serviceNameLower}Provider'
        ..modifier = isFamily ? FieldModifier.constant : FieldModifier.final$
        ..assignment = refer('_\$${serviceNameLower}NotifierProvider').code,
    );

    final providerExtension = Extension((b) => b
      ..name = '${serviceType}NotifierProviderExt'
      ..on = TypeReference((b) => b.symbol = '${serviceType}NotifierProvider')
      ..methods = ListBuilder([
        Method(
          (b) => b
            ..name = 'service'
            ..returns = TypeReference((b) => b.symbol = 'ProviderListenable<${serviceType}>')
            ..type = MethodType.getter
            ..body = refer('notifier').property('select').call([
              Method((b) => b
                ..lambda = true
                ..requiredParameters.add(Parameter((b) => b..name = 'n'))
                ..body = refer('n').property('service').code).closure
            ]).code,
        ),
        Method(
          (b) => b
            ..name = 'value'
            ..returns = TypeReference((b) => b.symbol = 'ProviderListenable<${stateType}>')
            ..type = MethodType.getter
            ..body = refer('select').call([
              Method((b) => b
                ..lambda = true
                ..requiredParameters.add(Parameter((b) => b..name = 's'))
                ..body = refer('s').property('value').code).closure
            ]).code,
        )
      ]));

    final serviceConstructorPositionalArguments = <Expression>[refer('ref')];
    final serviceConstructorNamedArguments = <String, Expression>{};
    final buildOptionalParameters = <Parameter>[];
    final buildRequiredParameters = <Parameter>[];

    for (final p in constructor.parameters) {
      final element = p.type.element;
      if (p.type is InvalidType ||
          (element is ClassElement &&
              (element.name == 'Ref' || element.allSupertypes.any((element) => element.element.name == 'Ref')))) {
        continue;
      }

      final parameter = Parameter((b) => b
        ..named = p.isNamed
        // This only controls the `required` keyword in the generated code.
        ..required = p.isNamed && p.isRequired
        ..name = p.name
        ..type = TypeReference((b) => b.symbol = p.type.getDisplayString()));

      final parameters = p.isRequired ? buildRequiredParameters : buildOptionalParameters;
      if (p.isNamed) {
        serviceConstructorNamedArguments[p.name] = refer(p.name);
      } else {
        serviceConstructorPositionalArguments.add(refer(p.name));
      }
      parameters.add(parameter);
    }

    final buildMethodBuilder = MethodBuilder()
      ..name = 'build'
      ..annotations = ListBuilder([CodeExpression(Code('override'))])
      ..returns = TypeReference((b) => b.symbol = 'ServiceState<$stateType>')
      ..optionalParameters = ListBuilder(buildOptionalParameters)
      ..requiredParameters = ListBuilder(buildRequiredParameters)
      ..body = Block.of([
        refer('service')
            .assign(refer(serviceType).call(serviceConstructorPositionalArguments, serviceConstructorNamedArguments))
            .statement,
        refer('_subscription')
            .assign(refer('service').property('listen').call([
              Method((b) => b
                ..lambda = true
                ..requiredParameters.add(Parameter((b) => b..name = 'state'))
                ..body = refer('this').property('state').assign(refer('state')).code).closure
            ]))
            .statement,
        refer('ref').property('onDispose').call([
          Method((b) => b
            ..body = Block.of([
              refer('_subscription').property('cancel').call([]).statement,
              if (closeOnDispose) refer('service').property('close').call([]).statement,
            ])).closure
        ]).statement,
        refer('service').property('state').returned.statement,
      ]);

    final updateShouldNotifyMethod = Method((b) => b
      ..docs = ListBuilder(['// Defer this decision to [service].'])
      ..annotations = ListBuilder([CodeExpression(Code('override'))])
      ..returns = refer('bool')
      ..name = 'updateShouldNotify'
      ..requiredParameters = ListBuilder([
        Parameter((b) => b
          ..name = 'old'
          ..type = TypeReference((b) => b.symbol = 'ServiceState<$stateType>')),
        Parameter((b) => b
          ..name = 'current'
          ..type = TypeReference((b) => b.symbol = 'ServiceState<$stateType>'))
      ])
      ..body = literalBool(true).code);

    final notifierClass = Class((b) => b
      ..annotations.add(CodeExpression(Code(annotationOut)))
      ..name = '_\$${serviceType}Notifier'
      ..extend = TypeReference((b) => b..symbol = '_\$\$${serviceClass.name}Notifier')
      ..fields.addAll([
        Field((f) => f
          ..name = 'service'
          ..late = true
          ..type = TypeReference((b) => b.symbol = serviceType)),
        Field((f) => f
          ..name = '_subscription'
          ..late = true
          ..type = TypeReference((b) => b.symbol = 'StreamSubscription')),
      ])
      ..methods.addAll([
        buildMethodBuilder.build(),
        updateShouldNotifyMethod,
      ]));

    final l = Library((b) => b
      ..body = ListBuilder([
        providerTypeDef,
        Code('\n'),
        providerDeclaration,
        Code('\n'),
        providerExtension,
        Code('\n'),
        notifierClass,
      ]));

    final out = formatter.format('${l.accept(emitter)}');
    buffer.write(out);
  }
}
