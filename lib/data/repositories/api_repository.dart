import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/church_model.dart';
import '../models/pastor_model.dart';
import '../services/api_service.dart';


final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiRepository(dio);
});

class ApiRepository {
  final Dio _dio;
  ApiRepository(this._dio);

  Future<List<Pastor>> getPastors() async {
    try {
      final response =
      await _dio.get('/pastors', queryParameters: {'limit': 100});
      final responseData = response.data['data'] as List;
      return responseData.map((json) => Pastor.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching pastors: $e');
      throw Exception('Failed to load pastors');
    }
  }

  Future<Pastor> addPastor(
      {required String fullName,
        required String email,
        required String password}) async {
    try {
      final response = await _dio.post(
        '/pastors',
        data: Pastor.creationToJson(
            fullName: fullName, email: email, password: password),
      );
      return Pastor.fromJson(response.data);
    } on DioException catch (e) {
      print('Error adding pastor: $e');
      throw Exception('Failed to add pastor');
    }
  }

  Future<void> removePastor(String userId) async {
    try {
      await _dio.delete('/pastors/$userId');
    } on DioException catch (e) {
      print('Error deleting pastor: $e');
      throw Exception('Failed to delete pastor');
    }
  }

  Future<List<Church>> getChurches() async {
    try {
      final response =
      await _dio.get('/churches', queryParameters: {'limit': 100});
      final responseData = response.data['data'] as List;
      return responseData.map((json) => Church.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching churches: $e');
      throw Exception('Failed to load churches');
    }
  }

  Future<Church> addChurch(Church church) async {
    try {
      final response = await _dio.post('/churches', data: church.toJson());
      return Church.fromJson(response.data);
    } on DioException catch (e) {
      print('Error adding church: $e');
      throw Exception('Failed to add church');
    }
  }

  Future<void> removeChurch(String id) async {
    try {
      await _dio.delete('/churches/$id');
    } on DioException catch (e) {
      print('Error deleting church: $e');
      throw Exception('Failed to delete church');
    }
  }
}