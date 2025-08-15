import 'package:meta/meta_meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_stateful_service/riverpod_stateful_service.dart';
import 'package:stateful_service/stateful_service.dart';

export 'dart:async' show StreamSubscription;

export 'package:meta/meta.dart' show protected;
export 'package:riverpod/misc.dart' show ProviderListenable;
export 'package:riverpod/riverpod.dart' show NotifierProvider, Ref;
export 'package:riverpod_stateful_service/riverpod_stateful_service.dart';
export 'package:stateful_service/stateful_service.dart';

/// An annotation placed on classes inheriting from [StatefulService] to generate a Riverpod provider for them.
@Target({TargetKind.classType})
class RiverpodService {
  const RiverpodService({this.keepAlive = false, this.dependencies, this.closeOnDispose = true, this.name, this.retry});

  /// Whether the state of the provider should be maintained if it is no-longer used.
  ///
  /// See [Riverpod.keepAlive].
  final bool keepAlive;

  /// The list of providers that this provider potentially depends on.
  ///
  /// See [Riverpod.dependencies].
  final List<Object>? dependencies;

  /// A label for the provider.
  ///
  /// See [ProviderOrFamily.name].
  final String? name;

  /// The retry strategy to use when a provider fails.
  ///
  /// See [ProviderOrFamily.retry].
  final Duration? retry;

  /// Use with care!
  ///
  /// Whether to close this provider's service when this notifier is disposed.
  ///
  /// See [StatefulServiceNotifierMixin.closeOnDispose].
  final bool closeOnDispose;
}

@Target({TargetKind.classType})
const riverpodService = RiverpodService();
