import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/data/repositories/mock_database.dart';

final mockDatabaseProvider = Provider<MockDatabase>((ref) => MockDatabase());

class MembersNotifier extends StateNotifier<List<Member>> {
  final MockDatabase _database;
  MembersNotifier(this._database) : super([]) {
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    state = await _database.getMembers();
  }

  Future<void> addMember(Member member) async {
    await _database.addMember(member);
    state = [...state, member];
  }

  Future<void> removeMember(String id) async {
    await _database.removeMember(id);
    state = state.where((m) => m.id != id).toList();
  }
}

final membersProvider = StateNotifierProvider<MembersNotifier, List<Member>>((ref) {
  return MembersNotifier(ref.read(mockDatabaseProvider));
});

class PastorsNotifier extends StateNotifier<List<Pastor>> {
  final MockDatabase _database;
  PastorsNotifier(this._database) : super([]) {
    _loadPastors();
  }

  Future<void> _loadPastors() async {
    state = await _database.getPastors();
  }

  Future<void> addPastor(Pastor pastor) async {
    await _database.addPastor(pastor);
    state = [...state, pastor];
  }

  Future<void> removePastor(String id) async {
    await _database.removePastor(id);
    state = state.where((p) => p.id != id).toList();
  }
}

final pastorsProvider = StateNotifierProvider<PastorsNotifier, List<Pastor>>((ref) {
  return PastorsNotifier(ref.read(mockDatabaseProvider));
});

class ChurchesNotifier extends StateNotifier<List<Church>> {
  final MockDatabase _database;
  ChurchesNotifier(this._database) : super([]) {
    _loadChurches();
  }

  Future<void> _loadChurches() async {
    state = await _database.getChurches();
  }

  Future<void> addChurch(Church church) async {
    await _database.addChurch(church);
    state = [...state, church];
  }

  Future<void> removeChurch(String id) async {
    await _database.removeChurch(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final churchesProvider = StateNotifierProvider<ChurchesNotifier, List<Church>>((ref) {
  return ChurchesNotifier(ref.read(mockDatabaseProvider));
});