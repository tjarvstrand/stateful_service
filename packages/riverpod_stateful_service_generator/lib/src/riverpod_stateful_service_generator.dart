import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_stateful_service_annotation/riverpod_stateful_service_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'parser_generator.dart';

const _providerTypeTemplate = r'''
typedef %ServiceName%NotifierProvider = NotifierProvider<_$%ServiceName%Notifier, ServiceState<%State%>>;

final %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _autoDisposeProviderTypeTemplate = r'''
typedef %ServiceName%NotifierProvider = AutoDisposeNotifierProvider<_$%ServiceName%Notifier, ServiceState<%State%>>;

final %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _providerFamilyTypeTemplate = r'''
typedef %ServiceName%NotifierProvider = _$%ServiceName%NotifierProvider;

const %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const _autoDisposeProviderFamilyTypeTemplate = r'''
typedef %ServiceName%NotifierProvider = _$%ServiceName%NotifierProvider;

const %ServiceNameLower%Provider = _$%ServiceNameLower%NotifierProvider;
''';

const template = r'''
%ProviderTypeTemplate%
extension %ServiceName%NotifierProviderExt on %ServiceName%NotifierProvider {
  ProviderListenable<%ServiceName%> get service => notifier.select((n) => n.service);
  ProviderListenable<%State%> get value => select((s) => s.value);
}

%RiverpodAnnotation%
class _$%ServiceName%Notifier extends _$$%ServiceName%Notifier {
  @override
  ServiceState<%State%> build(%BuildParameters%) {
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
  
  late %ServiceName% service;
  late StreamSubscription _subscription;
  final _closeOnDispose = %CloseOnDispose%;
  
  // Defer this decision to [service].
  @override
  bool updateShouldNotify(ServiceState<%State%> old, ServiceState<%State%> current) => true;
}
''';

const riverpodTypeChecker = TypeChecker.fromRuntime(Riverpod);

class MissingExtensionError extends InvalidGenerationSourceError {
  MissingExtensionError(String name, {super.todo = '', super.element})
      : super('The class $name must extend StatefulService');
}

class MissingUnnamedConstructorError extends InvalidGenerationSourceError {
  MissingUnnamedConstructorError(String name, {super.todo = '', super.element})
      : super('The class $name must declare an unnamed constructor');
}

class MissingImportError extends InvalidGenerationSourceError {
  MissingImportError(String file, String import, {super.todo = '', super.element})
      : super('The file $file must import $import');
}

class MissingRiverpodImportError extends MissingImportError {
  MissingRiverpodImportError(String file) : super(file, 'riverpod.dart');
}

class MissingRiverpodAnnotationImportError extends MissingImportError {
  MissingRiverpodAnnotationImportError(String file) : super(file, 'riverpod_annotation.dart');
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

      if (!hasRiverPodImport) {
        throw MissingRiverpodImportError(unit.declaredElement!.source.fullName);
      }

      if (!hasRiverPodAnnotationImport) {
        throw MissingRiverpodAnnotationImportError(unit.declaredElement!.source.fullName);
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
      final element = p.type.element;
      if (p.type is InvalidType ||
          (element is ClassElement &&
              (element.name == 'Ref' || element.allSupertypes.any((element) => element.element.name == 'Ref')))) {
        return;
      }
      if (p.isNamed) {
        if (p.isRequired) {
          named.write('required ');
        }
        p.appendToWithoutDelimiters(named);
        named.write(', ');

        constructorArguments.write('${p.name}: ${p.name}, ');
      } else {
        p.appendToWithoutDelimiters(positioned);
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
          .replaceAll('%ServiceNameLower%', serviceNameLower)
          .replaceFirst('%RiverpodAnnotation%', annotationOut)
          .replaceAll('%ServiceName%', serviceClass.name)
          .replaceAll('%State%', statefulServiceSupertype.typeArguments.first.getDisplayString())
          .replaceFirst('%BuildParameters%', buildParameters.join(', '))
          .replaceFirst('%ConstructorArguments%', constructorArguments.toString())
          .replaceFirst('%CloseOnDispose%', closeOnDispose?.expression.toString() ?? 'true'),
    );
  }
}
