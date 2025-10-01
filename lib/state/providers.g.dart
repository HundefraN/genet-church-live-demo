// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardStatsHash() => r'e81f7b6cd5ae62220a8c0690f40c0bebcf2cec88';

/// See also [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeFutureProvider<SuperAdminDashboardStats>.internal(
      dashboardStats,
      name: r'dashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardStatsRef =
    AutoDisposeFutureProviderRef<SuperAdminDashboardStats>;
String _$activityLogHash() => r'ae1ef2dccfc714dec40b5dfc6232e10decb41d5b';

/// See also [activityLog].
@ProviderFor(activityLog)
final activityLogProvider =
    AutoDisposeFutureProvider<List<ActivityLog>>.internal(
      activityLog,
      name: r'activityLogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityLogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityLogRef = AutoDisposeFutureProviderRef<List<ActivityLog>>;
String _$pastorsHash() => r'64e7c97210e364d8519c9b1fded0256f15e37ed4';

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
String _$churchesHash() => r'3a18e7f17935ab6e7d59dcbfd24bdf9e7ea8232c';

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
String _$departmentsHash() => r'b11b871b9383b8389baa02ad05d0d4900e5ac9a2';

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
String _$servantsHash() => r'393ad2e4f290325667b0249bcd0021fe5aa6973c';

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
String _$membersHash() => r'1a7da63434c693850509ffac9d0c8d7e5e48ce95';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
