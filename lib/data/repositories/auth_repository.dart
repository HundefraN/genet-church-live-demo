import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genet_church_portal/data/services/api_service.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(dioProvider), const FlutterSecureStorage());
});

final authStateProvider = StateProvider<bool>((ref) => false);

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);
    } catch (e) {
      // I can handle login errors more gracefully here
      print('Login failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}