import 'package:analyzer/dart/ast/ast.dart' hide Block, Expression;
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType, RecordType;
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
  String generateForUnit(Iterable<CompilationUnit> compilationUnits) {
    final buffer = StringBuffer();
    for (final unit in compilationUnits) {
      final importPrefixes = {
        for (final d in unit.directives.whereType<ImportDirective>())
          if (d.prefix != null) d.uri.stringValue!: '${d.prefix!.name}.'
      };
      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          _generateForClass(declaration, buffer, importPrefixes);
        }
      }
    }
    return buffer.toString();
  }

  String _typeDisplayString(DartType type, Map<String, String> importPrefixes) {
    final prefix = importPrefixes[type.element3?.library2?.uri.toString()] ?? '';
    return '$prefix${type.getDisplayString()}';
  }

  void _generateForClass(ClassDeclaration unit, StringBuffer buffer, Map<String, String> importPrefixes) {
    final annotation = unit.sortedCommentAndAnnotations.firstWhereOrNull(
      (node) =>
          node is Annotation &&
          (node.element2?.displayName == 'riverpodService' || node.element2?.displayName == 'RiverpodService'),
    ) as Annotation?;

    if (annotation == null) {
      return;
    }

    final serviceClass = unit.declaredFragment?.element;
    if (serviceClass == null) {
      return;
    }

    final serviceClassName = serviceClass.displayName;
    final serviceClassNameLower = '${serviceClassName.substring(0, 1).toLowerCase()}${serviceClassName.substring(1)}';

    final statefulServiceSupertype =
        serviceClass.allSupertypes.firstWhereOrNull((supertype) => supertype.element3.displayName == 'StatefulService');

    if (statefulServiceSupertype == null) {
      throw MissingExtensionError(serviceClass.displayName);
    }

    final annotationArguments =
        annotation.arguments?.arguments.whereType<NamedExpression>() ?? const <NamedExpression>[];

    final providerConstructorArguments = annotationArguments
        .where((arg) => arg.name.label.name != 'closeOnDispose' && arg.name.label.name != 'keepAlive')
        .map((arg) => arg.toString())
        .join(', ');

    final constructor = serviceClass.constructors2.firstWhereOrNull((element) {
      return element.displayName == serviceClassName;
    });

    if (constructor == null) {
      throw MissingUnnamedConstructorError(serviceClassName);
    }

    final isAutoDispose = !annotationArguments
        .any((arg) => arg.name.label.name == 'keepAlive' && arg.expression.beginToken.stringValue == 'true');

    final isFamily = constructor.formalParameters.length > 1;
    final familySuffix = isFamily ? 'Family' : '';

    final closeOnDispose = annotationArguments
        .any((arg) => arg.name.label.name == 'closeOnDispose' && arg.expression.beginToken.stringValue == 'true');

    final stateTypeName = _typeDisplayString(statefulServiceSupertype.typeArguments.first, importPrefixes);

    final statefulServicePrefix =
        importPrefixes['package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart'] ?? '';

    final providerExtension = Extension((b) => b
      ..name = '${serviceClassName}NotifierProviderExt'
      ..on = TypeReference((b) => b.symbol = '${serviceClassName}NotifierProvider')
      ..methods = ListBuilder([
        Method(
          (b) => b
            ..name = 'service'
            ..returns =
                TypeReference((b) => b.symbol = '${statefulServicePrefix}ProviderListenable<${serviceClassName}>')
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
            ..returns = TypeReference((b) => b.symbol = '${statefulServicePrefix}ProviderListenable<${stateTypeName}>')
            ..type = MethodType.getter
            ..body = refer('select').call([
              Method((b) => b
                ..lambda = true
                ..requiredParameters.add(Parameter((b) => b..name = 's'))
                ..body = refer('s').property('value').code).closure
            ]).code,
        )
      ]));

    final nonRefConstructorParameters = constructor.formalParameters.whereNot((p) {
      final element = p.type.element3;
      return p.type is InvalidType ||
          (element is ClassElement2 &&
              (element.displayName == 'Ref' ||
                  element.allSupertypes.any((superType) => superType.element3.displayName == 'Ref')));
    });
    final constructorHasRefParameter = constructor.formalParameters.length != nonRefConstructorParameters.length;
    final nonRefPositionalConstructorParameters = nonRefConstructorParameters.where((p) => !p.isNamed);
    final nonRefNamedConstructorParameters = nonRefConstructorParameters.where((p) => p.isNamed);

    final recordType = isFamily
        ? RecordType((b) => b
          ..positionalFieldTypes = ListBuilder([
            for (final p in nonRefPositionalConstructorParameters)
              TypeReference((b) => b..symbol = _typeDisplayString(p.type, importPrefixes)),
          ])
          ..namedFieldTypes = MapBuilder({
            for (final p in nonRefNamedConstructorParameters)
              p.displayName: TypeReference((b) => b..symbol = _typeDisplayString(p.type, importPrefixes)),
          }))
        : null;

    final providerTypeName = '${serviceClassName}NotifierProvider';

    final providerTypeDef = TypeDef((b) => b
      ..name = providerTypeName
      ..definition = TypeReference((b) => b
        ..symbol = '${statefulServicePrefix}StatefulServiceNotifierProvider'
        ..types = ListBuilder([
          TypeReference((b) => b..symbol = serviceClassName),
          TypeReference((b) => b..symbol = stateTypeName),
        ])));

    final providerFamilyTypeDef = recordType != null
        ? TypeDef((b) => b
          ..name = '${providerTypeName}Family'
          ..definition = TypeReference((b) => b
            ..symbol = '${statefulServicePrefix}StatefulServiceNotifierProviderFamily'
            ..types = ListBuilder([
              TypeReference((b) => b..symbol = serviceClassName),
              TypeReference((b) => b..symbol = stateTypeName),
              recordType,
            ])))
        : null;

    final notifierProviderVarName =
        isFamily ? '_\$${serviceClassNameLower}Provider' : '${serviceClassNameLower}Provider';

    final notifierProviderRef = refer('${statefulServicePrefix}NotifierProvider');
    final notifierProviderBase = switch ((isAutoDispose, isFamily)) {
      (true, true) => notifierProviderRef.property('autoDispose').property('family'),
      (true, false) => notifierProviderRef.property('autoDispose'),
      (false, true) => notifierProviderRef.property('family'),
      (false, false) => notifierProviderRef,
    };

    final wrapperDeclaration = isFamily
        ? Method((b) => b
          ..name = serviceClassNameLower + 'Provider'
          ..returns = TypeReference((b) => b..symbol = providerTypeName)
          ..requiredParameters.addAll([
            for (final p in nonRefPositionalConstructorParameters.where((p) => !p.isOptional))
              Parameter((b) => b
                ..name = p.displayName
                ..type = TypeReference((b) => b..symbol = _typeDisplayString(p.type, importPrefixes))),
          ])
          ..optionalParameters.addAll([
            for (final p in nonRefPositionalConstructorParameters.where((p) => p.isOptional))
              Parameter((b) => b
                ..name = p.displayName
                ..named = false
                ..type = TypeReference((b) => b..symbol = _typeDisplayString(p.type, importPrefixes))
                ..defaultTo = p.defaultValueCode != null ? Code(p.defaultValueCode!) : null),
            for (final p in nonRefNamedConstructorParameters)
              Parameter((b) => b
                ..name = p.displayName
                ..named = true
                ..required = p.isRequired
                ..type = TypeReference((b) => b..symbol = _typeDisplayString(p.type, importPrefixes))
                ..defaultTo = p.defaultValueCode != null ? Code(p.defaultValueCode!) : null),
          ])
          ..body = refer(notifierProviderVarName).call([
            literalRecord([
              ...nonRefPositionalConstructorParameters.map((p) => refer(p.displayName)),
            ], {
              for (final p in nonRefNamedConstructorParameters) p.displayName: refer(p.displayName),
            })
          ]).code)
        : null;

    final notifierProviderDeclaration = Field((b) => b
      ..type = TypeReference((b) => b..symbol = '$providerTypeName$familySuffix')
      ..name = notifierProviderVarName
      ..modifier = FieldModifier.final$
      ..assignment = notifierProviderBase.call([
        Method(
          (b) => b
            ..lambda = true
            ..requiredParameters = ListBuilder([
              if (isFamily) Parameter((b) => b..name = 'arg'),
            ])
            ..body = refer('${statefulServicePrefix}StatefulServiceNotifier').call([
              Method((b) => b
                ..lambda = true
                ..requiredParameters = ListBuilder([Parameter((b) => b..name = 'ref')])
                ..body = refer(serviceClassName).call([
                  if (constructorHasRefParameter) refer('ref'),
                  for (final (i, _) in nonRefPositionalConstructorParameters.indexed) refer('arg.\$${i + 1}'),
                ], {
                  for (final p in nonRefNamedConstructorParameters) p.displayName: refer('arg.${p.displayName}'),
                }).code).closure,
            ], {
              if (closeOnDispose) 'closeOnDispose': literalBool(true),
            }).code,
        ).closure,
        if (providerConstructorArguments.isNotEmpty) CodeExpression(Code(providerConstructorArguments)),
      ]).code);

    final l = Library((b) => b
      ..comments = ListBuilder(['ignore_for_file: unnecessary_lambdas'])
      ..body = ListBuilder([
        providerTypeDef,
        Code('\n'),
        if (providerFamilyTypeDef != null) ...[
          providerFamilyTypeDef,
          Code('\n'),
        ],
        providerExtension,
        Code('\n'),
        if (wrapperDeclaration != null) ...[
          wrapperDeclaration,
          Code('\n\n'),
        ],
        notifierProviderDeclaration,
        // notifierClass,
      ]));

    final out = formatter.format('${l.accept(emitter)}');
    buffer.write(out);
  }
}
