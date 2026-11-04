import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noticewise/core/utils/logger.dart';

/// Logs Riverpod provider state changes in debug builds.
///
/// Registered in [ProviderScope] only when [kDebugMode] is true.
/// Riverpod 3.x uses [ProviderObserverContext] instead of [ProviderBase].
base class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    logger.d(
      '[Provider] ${context.provider.name ?? context.provider.runtimeType}: '
      '$previousValue → $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    logger.e(
      '[Provider] ${context.provider.name ?? context.provider.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
