part of 'church_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentChurchHash() => r'fbedf0d28fba472176e7d28f60e4ea5101ac2856';

/// See also [CurrentChurch].
@ProviderFor(CurrentChurch)
final currentChurchProvider =
AutoDisposeNotifierProvider<CurrentChurch, String?>.internal(
  CurrentChurch.new,
  name: r'currentChurchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentChurchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentChurch = AutoDisposeNotifier<String?>;