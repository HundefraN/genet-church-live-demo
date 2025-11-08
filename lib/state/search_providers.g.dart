// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$debouncedSearchQueryHash() =>
    r'b99900120c947a13c8431f7999a6536651044a2e';

/// See also [debouncedSearchQuery].
@ProviderFor(debouncedSearchQuery)
final debouncedSearchQueryProvider = AutoDisposeFutureProvider<String>.internal(
  debouncedSearchQuery,
  name: r'debouncedSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$debouncedSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DebouncedSearchQueryRef = AutoDisposeFutureProviderRef<String>;
String _$searchResultsHash() => r'9bd9db6279a76d4844ccbb1b7dbce48c29e41d31';

/// See also [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider =
    AutoDisposeFutureProvider<List<SearchCommand>>.internal(
      searchResults,
      name: r'searchResultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchResultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchResultsRef = AutoDisposeFutureProviderRef<List<SearchCommand>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
