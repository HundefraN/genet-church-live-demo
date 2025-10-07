import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/dashboard_model.dart';
import 'package:genet_church_portal/data/models/department_model.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/data/models/servant_model.dart';
import 'package:genet_church_portal/data/services/api_service.dart';

import '../../features/screens/lib/features/screens/lib/data/models/lib/data/models/pastor_dashboard_model.dart';
import '../../features/screens/lib/features/screens/lib/data/models/session_model.dart';

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiRepository(dio);
});

class ApiRepository {
  final Dio _dio;
  ApiRepository(this._dio);

  Future<SuperAdminDashboardStats> getSuperAdminDashboardStats() async {
    final response = await _dio.get('/dashboard/super-admin');
    return SuperAdminDashboardStats.fromJson(response.data);
  }

  Future<PastorDashboardStats> getPastorDashboardStats() async {
    final response = await _dio.get('/dashboard/pastor');
    return PastorDashboardStats.fromJson(response.data);
  }

  Future<void> addMember({required Member member, required String churchId}) async {
    await _dio.post(
      '/church-members',
      queryParameters: {'churchId': churchId},
      data: member.toJson(),
    );
  }

  Future<List<Pastor>> getPastors() async {
    final response = await _dio.get('/pastors', queryParameters: {'limit': 100});
    final responseData = response.data['data'] as List;
    return responseData.map((json) => Pastor.fromJson(json)).toList();
  }

  Future<Pastor> addPastor({required String fullName, required String email, required String password}) async {
    final response = await _dio.post('/pastors', data: {'fullName': fullName, 'email': email, 'password': password});
    return Pastor.fromJson(response.data);
  }

  Future<Pastor> updatePastor({required String pastorId, required String fullName, required String email}) async {
    final response = await _dio.patch('/pastors/$pastorId', data: {'fullName': fullName, 'email': email});
    return Pastor.fromJson(response.data);
  }

  Future<void> removePastor(String userId) async {
    await _dio.delete('/pastors/$userId');
  }

  Future<Pastor> assignChurchToPastor({required String pastorId, required String churchId}) async {
    final response = await _dio.patch('/pastors/$pastorId/assign-church', data: {'churchId': churchId});
    return Pastor.fromJson(response.data);
  }

  Future<List<Church>> getChurches() async {
    final response = await _dio.get('/churches', queryParameters: {'limit': 100});
    final responseData = response.data['data'] as List;
    return responseData.map((json) => Church.fromJson(json)).toList();
  }

  Future<Church> addChurch(Church church) async {
    final response = await _dio.post('/churches', data: church.toJson());
    return Church.fromJson(response.data);
  }

  Future<Church> updateChurch({required String churchId, required Church church}) async {
    final response = await _dio.patch('/churches/$churchId', data: church.toJson());
    return Church.fromJson(response.data);
  }

  Future<void> removeChurch(String id) async {
    await _dio.delete('/churches/$id');
  }

  Future<List<Department>> getDepartments(String churchId) async {
    final response = await _dio.get('/departments', queryParameters: {'churchId': churchId});
    final responseData = response.data as List;
    return responseData.map((json) => Department.fromJson(json)).toList();
  }

  Future<Department> addDepartment({required String name, required String churchId}) async {
    final response = await _dio.post('/departments', data: {'name': name}, queryParameters: {'churchId': churchId});
    return Department.fromJson(response.data);
  }

  Future<Department> updateDepartment({required String departmentId, required String name}) async {
    final response = await _dio.patch('/departments/$departmentId', data: {'name': name});
    return Department.fromJson(response.data);
  }

  Future<void> removeDepartment(String id) async {
    await _dio.delete('/departments/$id');
  }

  Future<Servant> assignServantToDepartment({required String departmentId, required String servantId}) async {
    final response = await _dio.post('/departments/$departmentId/assign-servant', data: {'servantId': servantId});
    return Servant.fromJson(response.data);
  }

  Future<List<Servant>> getServants(String churchId) async {
    final response = await _dio.get('/servants', queryParameters: {'churchId': churchId, 'limit': 100});
    final responseData = response.data['data'] as List;
    return responseData.map((json) => Servant.fromJson(json)).toList();
  }

  Future<Servant> addServant({required String fullName, required String email, required String password, required String churchId}) async {
    final response = await _dio.post('/servants', data: {'fullName': fullName, 'email': email, 'password': password}, queryParameters: {'churchId': churchId});
    return Servant.fromJson(response.data);
  }

  Future<Servant> updateServant({required String servantId, required String fullName}) async {
    final response = await _dio.patch('/servants/$servantId', data: {'fullName': fullName});
    return Servant.fromJson(response.data);
  }

  Future<void> removeServant(String id) async {
    await _dio.delete('/servants/$id');
  }

  Future<List<Session>> getSessions() async {
    final currentSessionResponse = await _dio.get('/sessions/current');
    final allSessionsResponse = await _dio.get('/sessions/all');

    final currentSessionId = currentSessionResponse.data['id'];
    final sessionsList = (allSessionsResponse.data as List)
        .map((json) => Session.fromJson(json, currentSessionId: currentSessionId))
        .toList();

    sessionsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessionsList;
  }

  Future<void> revokeSession(String sessionId) async {
    await _dio.delete('/sessions/$sessionId');
  }
}