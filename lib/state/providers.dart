import 'package:genet_church_portal/data/models/paginated_response.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/new_item_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:genet_church_portal/data/models/activity_log_model.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/dashboard_model.dart';
import 'package:genet_church_portal/data/models/department_model.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/data/models/pastor_dashboard_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/data/models/servant_model.dart';
import 'package:genet_church_portal/data/repositories/api_repository.dart';

import '../data/models/dashboard_base_model.dart';

part 'providers.g.dart';

final dashboardStatsProvider =
FutureProvider.autoDispose<DashboardStatsBase?>((ref) async {
  final user = ref.watch(authStateProvider);
  final api = ref.watch(apiRepositoryProvider);

  if (user == null) {
    return null;
  }

  switch (user.role.toUpperCase()) {
    case 'SUPER_ADMIN':
      return await api.getSuperAdminDashboardStats();
    case 'PASTOR':
      return await api.getPastorDashboardStats() as DashboardStatsBase?;
    default:
      return null;
  }
});

@riverpod
class Pastors extends _$Pastors {
  @override
  Future<List<Pastor>> build() {
    return ref.watch(apiRepositoryProvider).getPastors();
  }

  Future<Pastor> addPastor(
      {required String fullName,
        required String email,
        required String password}) async {
    final api = ref.read(apiRepositoryProvider);
    final newPastor =
    await api.addPastor(fullName: fullName, email: email, password: password);
    ref.invalidateSelf();
    await future;
    return newPastor;
  }

  Future<void> updatePastor(
      {required String pastorId,
        required String fullName,
        required String email}) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updatePastor(
          pastorId: pastorId, fullName: fullName, email: email);
      return api.getPastors();
    });
  }

  Future<void> assignChurchToPastor(
      {required String pastorId, required String churchId}) async {
    final api = ref.read(apiRepositoryProvider);
    await api.assignChurchToPastor(pastorId: pastorId, churchId: churchId);
    ref.invalidateSelf();
    await future;
  }

  Future<void> removePastor(String pastorId) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.removePastor(pastorId);
      return api.getPastors();
    });
  }
}

@riverpod
class Churches extends _$Churches {
  @override
  Future<List<Church>> build() {
    return ref.watch(apiRepositoryProvider).getChurches();
  }

  Future<Church> addChurch(Church church) async {
    final api = ref.read(apiRepositoryProvider);
    final newChurch = await api.addChurch(church);
    ref.invalidateSelf();
    await future;
    return newChurch;
  }

  Future<void> updateChurch(
      {required String churchId, required Church church}) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updateChurch(churchId: churchId, church: church);
      return api.getChurches();
    });
  }

  Future<void> removeChurch(String id) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.removeChurch(id);
      return api.getChurches();
    });
  }
}

@riverpod
class Departments extends _$Departments {
  @override
  Future<List<Department>> build() {
    final churchId = ref.watch(currentChurchProvider);
    if (churchId == null) return Future.value([]);
    return ref.watch(apiRepositoryProvider).getDepartments(churchId);
  }

  Future<void> addDepartment({required String name}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    await api.addDepartment(name: name, churchId: churchId);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateDepartment(
      {required String departmentId, required String name}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updateDepartment(departmentId: departmentId, name: name);
      return api.getDepartments(churchId);
    });
  }

  Future<void> removeDepartment(String id) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.removeDepartment(id);
      return api.getDepartments(churchId);
    });
  }
}

@riverpod
class Servants extends _$Servants {
  @override
  Future<List<Servant>> build() {
    final churchId = ref.watch(currentChurchProvider);
    if (churchId == null) return Future.value([]);
    return ref.watch(apiRepositoryProvider).getServants(churchId);
  }

  Future<Servant> addServant(
      {required String fullName,
        required String email,
        required String password}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    final newServant = await api.addServant(
        fullName: fullName, email: email, password: password, churchId: churchId);
    ref.invalidateSelf();
    await future;
    return newServant;
  }

  Future<void> updateServant(
      {required String servantId, required String fullName}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updateServant(servantId: servantId, fullName: fullName);
      return api.getServants(churchId);
    });
  }

  Future<void> assignToDepartment(
      {required String departmentId, required String servantId}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.assignServantToDepartment(
          departmentId: departmentId, servantId: servantId);
      return api.getServants(churchId);
    });
  }

  Future<void> removeServant(String id) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) throw Exception('A church must be selected.');
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.removeServant(id);
      return api.getServants(churchId);
    });
  }
}

@riverpod
class Members extends _$Members {
  @override
  void build() {}

  Future<void> addMember({required Member member}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) {
      throw Exception("No church selected.");
    }
    await ref
        .read(apiRepositoryProvider)
        .addMember(member: member, churchId: churchId);
    ref.invalidate(membersListProvider);
  }
}

class MemberListState {
  final List<Member> members;
  final int page;
  final bool hasMore;
  final bool isFetchingNextPage;

  const MemberListState({
    this.members = const [],
    this.page = 1,
    this.hasMore = true,
    this.isFetchingNextPage = false,
  });

  MemberListState copyWith({
    List<Member>? members,
    int? page,
    bool? hasMore,
    bool? isFetchingNextPage,
  }) {
    return MemberListState(
      members: members ?? this.members,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
    );
  }
}

@riverpod
class MembersList extends _$MembersList {
  final int _limit = 20;

  @override
  Future<MemberListState> build() async {
    final churchId = ref.watch(currentChurchProvider);
    if (churchId == null)
      return const MemberListState(hasMore: false, members: []);

    final result = await ref
        .read(apiRepositoryProvider)
        .getMembers(churchId, page: 1, limit: _limit);
    return MemberListState(
      members: result.data,
      page: 1,
      hasMore: result.currentPage < result.totalPages,
    );
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isFetchingNextPage) return;

    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) return;

    state = AsyncData(currentState.copyWith(isFetchingNextPage: true));

    final nextPage = currentState.page + 1;
    try {
      final result = await ref
          .read(apiRepositoryProvider)
          .getMembers(churchId, page: nextPage, limit: _limit);

      state = AsyncValue.data(
        currentState.copyWith(
          members: [...currentState.members, ...result.data],
          page: nextPage,
          hasMore: result.currentPage < result.totalPages,
          isFetchingNextPage: false,
        ),
      );
    } catch (e, s) {
      state = AsyncData(currentState.copyWith(isFetchingNextPage: false));
    }
  }
}

@riverpod
class ActivityLog extends _$ActivityLog {
  @override
  Future<List<ActivityLogItem>> build() async {
    final user = ref.watch(authStateProvider);
    if (user?.role.toUpperCase() != 'SUPER_ADMIN') {
      return [];
    }
    final churches = await ref.watch(churchesProvider.future);
    final pastors = await ref.watch(pastorsProvider.future);

    final List<ActivityLogItem> activities = [];

    activities.addAll(pastors.map((p) => ActivityLogItem(
      title: 'New Pastor Added',
      subtitle: '${p.user.fullName} joined the pastoral team.',
      timestamp: DateTime.parse(p.user.createdAt),
      type: ActivityType.pastor,
      path: '/report-pastors',
    )));

    activities.addAll(churches.map((c) => ActivityLogItem(
      title: 'New Church Registered',
      subtitle: '${c.name} is now part of the network.',
      timestamp:
      DateTime.parse(c.dateCreated ?? DateTime.now().toIso8601String()),
      type: ActivityType.church,
      path: '/report-churchs',
    )));

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }
}