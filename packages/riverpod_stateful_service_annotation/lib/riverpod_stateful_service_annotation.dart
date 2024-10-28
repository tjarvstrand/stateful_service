import 'package:meta/meta_meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stateful_service/stateful_service.dart';

export 'dart:async' show StreamSubscription;

export 'package:meta/meta.dart' show protected;
export 'package:riverpod/riverpod.dart' show ProviderListenable;
export 'package:riverpod_annotation/riverpod_annotation.dart'
    hide
        AsyncNotifierProviderImpl,
        AutoDisposeAsyncNotifierProviderImpl,
        AutoDisposeNotifierProviderImpl,
        AutoDisposeStreamNotifierProviderImpl,
        BuildlessAsyncNotifier,
        BuildlessAutoDisposeAsyncNotifier,
        BuildlessAutoDisposeNotifier,
        BuildlessAutoDisposeStreamNotifier,
        BuildlessNotifier,
        BuildlessStreamNotifier,
        FamilyOverride,
        NotifierProviderImpl,
        ProviderOverride,
        StreamNotifierProviderImpl;

/// An annotation placed on classes inheriting from [StatefulService] to generate a Riverpod provider for them.
@Target({TargetKind.classType})
class RiverpodService {
  const RiverpodService({this.keepAlive = false, this.dependencies, this.closeOnDispose = true});

  /// Whether the state of the provider should be maintained if it is no-longer used.
  ///
  /// See [Riverpod] documentation for more information.
  final bool keepAlive;

  /// The list of providers that this provider potentially depends on.
  ///
  /// See [Riverpod] documentation for more information.
  final List<Object>? dependencies;

  /// Whether to close the underlying service when the provider is disposed.
  final bool closeOnDispose;
}

@Target({TargetKind.classType})
const riverpodService = RiverpodService();
