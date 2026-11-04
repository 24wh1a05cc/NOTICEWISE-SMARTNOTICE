// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noticeRepository)
final noticeRepositoryProvider = NoticeRepositoryProvider._();

final class NoticeRepositoryProvider
    extends
        $FunctionalProvider<
          NoticeRepository,
          NoticeRepository,
          NoticeRepository
        >
    with $Provider<NoticeRepository> {
  NoticeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticeRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoticeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoticeRepository create(Ref ref) {
    return noticeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoticeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoticeRepository>(value),
    );
  }
}

String _$noticeRepositoryHash() => r'cc9947bf2b8bc78cda0bf06d95888e5230c1db93';

/// Loads all notices from SQLite.
///
/// State: [AsyncValue<List<Notice>>]
///   - [AsyncLoading] while the database query is running
///   - [AsyncData] with the list on success
///   - [AsyncError] if the query fails

@ProviderFor(NoticesController)
final noticesControllerProvider = NoticesControllerProvider._();

/// Loads all notices from SQLite.
///
/// State: [AsyncValue<List<Notice>>]
///   - [AsyncLoading] while the database query is running
///   - [AsyncData] with the list on success
///   - [AsyncError] if the query fails
final class NoticesControllerProvider
    extends $AsyncNotifierProvider<NoticesController, List<Notice>> {
  /// Loads all notices from SQLite.
  ///
  /// State: [AsyncValue<List<Notice>>]
  ///   - [AsyncLoading] while the database query is running
  ///   - [AsyncData] with the list on success
  ///   - [AsyncError] if the query fails
  NoticesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticesControllerHash();

  @$internal
  @override
  NoticesController create() => NoticesController();
}

String _$noticesControllerHash() => r'9c29c563d30174dda428b15bbe8853c29f00c108';

/// Loads all notices from SQLite.
///
/// State: [AsyncValue<List<Notice>>]
///   - [AsyncLoading] while the database query is running
///   - [AsyncData] with the list on success
///   - [AsyncError] if the query fails

abstract class _$NoticesController extends $AsyncNotifier<List<Notice>> {
  FutureOr<List<Notice>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Notice>>, List<Notice>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Notice>>, List<Notice>>,
              AsyncValue<List<Notice>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
