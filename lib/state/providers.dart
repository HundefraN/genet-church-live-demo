import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genet_church_portal/data/models/activity_log_model.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/dashboard_model.dart';
import 'package:genet_church_portal/data/models/department_model.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/data/models/servant_model.dart';
import 'package:genet_church_portal/data/repositories/api_repository.dart';

part 'providers.g.dart';

@riverpod
Future<SuperAdminDashboardStats> dashboardStats(DashboardStatsRef ref) {
  return ref.watch(apiRepositoryProvider).getSuperAdminDashboardStats();
}

@riverpod
class Pastors extends _$Pastors {
  @override
  Future<List<Pastor>> build() {
    return ref.watch(apiRepositoryProvider).getPastors();
  }

  Future<void> addPastor(
      {required String fullName,
        required String email,
        required String password}) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.addPastor(fullName: fullName, email: email, password: password);
      return api.getPastors();
    });
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.assignChurchToPastor(pastorId: pastorId, churchId: churchId);
      return api.getPastors();
    });
  }

  Future<void> removePastor(String userId) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.removePastor(userId);
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

  Future<void> addChurch(Church church) async {
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.addChurch(church);
      return api.getChurches();
    });
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
    if (churchId == null) {
      throw Exception('A church must be selected to add a department.');
    }
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.addDepartment(name: name, churchId: churchId);
      return api.getDepartments(churchId);
    });
  }

  Future<void> removeDepartment(String id) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) {
      throw Exception('A church must be selected to remove a department.');
    }
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

  Future<void> addServant(
      {required String fullName,
        required String email,
        required String password}) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) {
      throw Exception('A church must be selected to add a servant.');
    }
    final api = ref.read(apiRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.addServant(
          fullName: fullName,
          email: email,
          password: password,
          churchId: churchId);
      return api.getServants(churchId);
    });
  }

  Future<void> removeServant(String id) async {
    final churchId = ref.read(currentChurchProvider);
    if (churchId == null) {
      throw Exception('A church must be selected to remove a servant.');
    }
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
      throw Exception("No church selected. Please select a church from the header before adding a member.");
    }
    await ref
        .read(apiRepositoryProvider)
        .addMember(member: member, churchId: churchId);
  }
}

@riverpod
Future<List<ActivityLog>> activityLog(ActivityLogRef ref) async {
  final churches = await ref.watch(churchesProvider.future);
  final pastors = await ref.watch(pastorsProvider.future);

  final List<ActivityLog> activities = [];

  activities.addAll(pastors.map((p) => ActivityLog(
    title: 'New Pastor Added',
    subtitle: '${p.user.fullName} joined the pastoral team.',
    timestamp: DateTime.parse(p.user.createdAt),
    type: ActivityType.pastor,
    path: '/report-pastors',
  )));

  activities.addAll(churches.map((c) => ActivityLog(
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