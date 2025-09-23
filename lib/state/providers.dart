import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/data/repositories/api_repository.dart';

class PastorsNotifier extends StateNotifier<List<Pastor>> {
  final ApiRepository _repository;
  PastorsNotifier(this._repository) : super([]) {
    _loadPastors();
  }

  Future<void> _loadPastors() async {
    try {
      state = await _repository.getPastors();
    } catch (e) {
      print(e);
      state = [];
    }
  }

  Future<void> addPastor(
      {required String fullName,
        required String email,
        required String password}) async {
    try {
      await _repository.addPastor(
          fullName: fullName, email: email, password: password);
      await _loadPastors();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removePastor(String userId) async {
    try {
      await _repository.removePastor(userId);
      await _loadPastors();
    } catch (e) {
      print(e);
    }
  }
}

final pastorsProvider =
StateNotifierProvider<PastorsNotifier, List<Pastor>>((ref) {
  return PastorsNotifier(ref.read(apiRepositoryProvider));
});

class ChurchesNotifier extends StateNotifier<List<Church>> {
  final ApiRepository _repository;
  ChurchesNotifier(this._repository) : super([]) {
    loadChurches();
  }

  Future<List<Church>> loadChurches() async {
    try {
      final churches = await _repository.getChurches();
      if (mounted) {
        state = churches;
      }
      return churches;
    } catch (e) {
      print(e);
      if (mounted) {
        state = [];
      }
      return [];
    }
  }

  Future<void> addChurch(Church church) async {
    try {
      await _repository.addChurch(church);
      await loadChurches();
    } catch (e) {
      print("Error in ChurchesNotifier addChurch: $e");
      rethrow;
    }
  }

  Future<void> removeChurch(String id) async {
    try {
      await _repository.removeChurch(id);
      state = state.where((c) => c.id != id).toList();
    } catch (e) {
      print("Error in ChurchesNotifier removeChurch: $e");
      await loadChurches();
      rethrow;
    }
  }
}
final churchesProvider =
StateNotifierProvider<ChurchesNotifier, List<Church>>((ref) {
  return ChurchesNotifier(ref.read(apiRepositoryProvider));
});