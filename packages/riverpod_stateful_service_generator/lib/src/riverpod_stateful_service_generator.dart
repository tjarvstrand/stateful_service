import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/src/riverpod_annotation.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'parser_generator.dart';

const _providerTypeTemplate = r'''
typedef %ServiceName%Ref = NotifierProviderRef<%State%>;
typedef %ServiceName%NotifierProvider = NotifierProvider<_$%ServiceName%Notifier, %State%>;

final %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _autoDisposeProviderTypeTemplate = r'''
typedef %ServiceName%Ref = AutoDisposeNotifierProviderRef<%State%>;
typedef %ServiceName%NotifierProvider = AutoDisposeNotifierProvider<_$%ServiceName%Notifier, %State%>;

final %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _providerFamilyTypeTemplate = r'''
typedef %ServiceName%Ref = NotifierProviderRef<%State%>;
typedef %ServiceName%NotifierProvider = _$%ServiceName%NotifierProvider;

const %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _autoDisposeProviderFamilyTypeTemplate = r'''
typedef %ServiceName%Ref = AutoDisposeNotifierProviderRef<%State%>;
typedef %ServiceName%NotifierProvider = _$%ServiceName%NotifierProvider;

const %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _autoDisposeExtensionsTemplate = r'''
  
''';

const _keepAliveExtensionsTemplate = r'''
  
''';

const template = r'''
%ProviderTypeTemplate%

extension %ServiceName%NotifierProviderExt on %ServiceName%NotifierProvider {
  ProviderListenable<%ServiceName%> get service => notifier.select((n) => n.service);
}

%RiverpodAnnotation%
class _$%ServiceName%Notifier extends _$$%ServiceName%Notifier {
  @override
  %State% build(%BuildParameters%) {
    service = %ServiceName%(%ConstructorArguments%);
    _subscription = service.listen((state) => this.state = state);
    ref.onDispose(() {
      _subscription.cancel();
      if(_closeOnDispose) {
        service.close();
      }
    });
    return service.state;
  }
  
  late final %ServiceName% service;
  late final StreamSubscription _subscription;
  final _closeOnDispose = %CloseOnDispose%;
  
  // Defer this decision to [service].
  @override
  bool updateShouldNotify(%State% old, %State% current) => true;
}
''';

const riverpodTypeChecker = TypeChecker.fromRuntime(Riverpod);

class MissingExtensionError extends InvalidGenerationSourceError {
  MissingExtensionError(String name, {super.todo = '', super.element})
      : super('The class $name must extend StatefulService');
}

class MissingUnnamedConstructorError extends InvalidGenerationSourceError {
  MissingUnnamedConstructorError(String name, {super.todo = '', super.element})
      : super('The class $name declare an unnamed constructor');
}

@immutable
class RiverpodStatefulServiceGenerator extends ParserGenerator<RiverpodService> {
  @override
  String generateForUnit(List<CompilationUnit> compilationUnits) {
    final buffer = StringBuffer();
    for (final unit in compilationUnits) {
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
    final annotationOut = annotationArguments == null ? '@riverpod' : '@Riverpod(${annotationArguments})';

    final constructor = serviceClass.children.firstWhereOrNull((element) {
      return element is ConstructorElement && element.name.isEmpty;
    }) as ConstructorElement?;

    if (constructor == null) {
      throw MissingUnnamedConstructorError(serviceClass.name);
    }

    final positioned = StringBuffer();
    final named = StringBuffer();
    final constructorArguments = StringBuffer('ref, ');
    final keepAlive = annotation.arguments?.arguments
        .firstWhereOrNull((arg) => arg is NamedExpression && arg.name.label.name == 'keepAlive') as NamedExpression?;

    final isFamily = constructor.parameters.length > 1;
    final isAutoDispose = keepAlive?.expression.toString() != 'true';

    constructor.parameters.forEach((p) {
      if (p.type is InvalidType) {
        return;
      }
      if (p.isNamed) {
        if (p.isRequired) {
          named.write('required ');
        }
        p.appendToWithoutDelimiters(named, withNullability: true);
        named.write(', ');

        constructorArguments.write('${p.name}: ${p.name}, ');
      } else {
        p.appendToWithoutDelimiters(positioned, withNullability: true);
        positioned.write(', ');
        constructorArguments.write('${p.name}, ');
      }
    });
    final buildParameters = [
      if (positioned.isNotEmpty) positioned.toString().substring(0, positioned.length - 2),
      if (named.isNotEmpty) '{${named.toString()}}',
    ];

    final closeOnDispose = annotation.arguments?.arguments
            .firstWhereOrNull((arg) => arg is NamedExpression && arg.name.label.name == 'closeOnDispose')
        as NamedExpression?;

    final serviceNameLower = '${serviceClass.name.substring(0, 1).toLowerCase()}${serviceClass.name.substring(1)}';

    buffer.write(
      template
          .replaceFirst(
            '%ProviderTypeTemplate%',
            isAutoDispose
                ? isFamily
                    ? _autoDisposeProviderFamilyTypeTemplate
                    : _autoDisposeProviderTypeTemplate
                : isFamily
                    ? _providerFamilyTypeTemplate
                    : _providerTypeTemplate,
          )
          .replaceAll(
              '%ExtensionsTemplate%',
              keepAlive?.expression.toString() == 'true'
                  ? _keepAliveExtensionsTemplate
                  : _autoDisposeExtensionsTemplate)
          .replaceAll('%ServiceNameLower%', serviceNameLower)
          .replaceFirst('%RiverpodAnnotation%', annotationOut)
          .replaceAll('%ServiceName%', serviceClass.name)
          .replaceAll('%State%', statefulServiceSupertype.typeArguments.first.getDisplayString(withNullability: true))
          .replaceFirst('%BuildParameters%', buildParameters.join(', '))
          .replaceFirst('%ConstructorArguments%', constructorArguments.toString())
          .replaceFirst('%CloseOnDispose%', closeOnDispose?.expression.toString() ?? 'true'),
    );
  }
}
