import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/riverpod_stateful_service_generator.dart';

/// Builds generators for `build_runner` to run
Builder riverpodServiceBuilder(BuilderOptions options) {
  final format = options.config['formatter'];
  return format == null
      ? PartBuilder([RiverpodStatefulServiceGenerator()], '.stateful_service.dart')
      : PartBuilder([RiverpodStatefulServiceGenerator()], '.stateful_service.dart', formatOutput: format);
}
