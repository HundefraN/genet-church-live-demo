// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pastorsHash() => r'ea2633af107e1799b597d742544fb02e9aef1208';

/// See also [Pastors].
@ProviderFor(Pastors)
final pastorsProvider =
    AutoDisposeAsyncNotifierProvider<Pastors, List<Pastor>>.internal(
      Pastors.new,
      name: r'pastorsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pastorsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Pastors = AutoDisposeAsyncNotifier<List<Pastor>>;
String _$churchesHash() => r'5a5b498343b3c0e754edb4dc4b236bbdeaa55ba0';

/// See also [Churches].
@ProviderFor(Churches)
final churchesProvider =
    AutoDisposeAsyncNotifierProvider<Churches, List<Church>>.internal(
      Churches.new,
      name: r'churchesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$churchesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Churches = AutoDisposeAsyncNotifier<List<Church>>;
String _$departmentsHash() => r'c97233c4f4af0c8421cd15cf6b6f49aaa03c2f69';

/// See also [Departments].
@ProviderFor(Departments)
final departmentsProvider =
    AutoDisposeAsyncNotifierProvider<Departments, List<Department>>.internal(
      Departments.new,
      name: r'departmentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$departmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Departments = AutoDisposeAsyncNotifier<List<Department>>;
String _$servantsHash() => r'484726495c564457a105a2d0867d3145fa2579a5';

/// See also [Servants].
@ProviderFor(Servants)
final servantsProvider =
    AutoDisposeAsyncNotifierProvider<Servants, List<Servant>>.internal(
      Servants.new,
      name: r'servantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$servantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Servants = AutoDisposeAsyncNotifier<List<Servant>>;
String _$membersHash() => r'e19ee34dac17eea457e61f5bfbd1127a1a2a7a2a';

/// See also [Members].
@ProviderFor(Members)
final membersProvider = AutoDisposeNotifierProvider<Members, void>.internal(
  Members.new,
  name: r'membersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$membersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Members = AutoDisposeNotifier<void>;
String _$activityLogHash() => r'8b1ff53f4eeabd9e8f397e20523eb2ee03a555c6';

/// See also [ActivityLog].
@ProviderFor(ActivityLog)
final activityLogProvider =
    AutoDisposeAsyncNotifierProvider<
      ActivityLog,
      List<ActivityLogItem>
    >.internal(
      ActivityLog.new,
      name: r'activityLogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityLogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActivityLog = AutoDisposeAsyncNotifier<List<ActivityLogItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
