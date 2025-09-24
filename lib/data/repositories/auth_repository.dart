import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(dioProvider), const FlutterSecureStorage());
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, UserModel?>((ref) {
  return AuthStateNotifier(ref.read(authRepositoryProvider));
});

class AuthStateNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _authRepository;
  AuthStateNotifier(this._authRepository) : super(null) {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    state = await _authRepository.getCurrentUser();
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    await _authRepository.login(email, password, rememberMe);
    state = await _authRepository.getCurrentUser();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = null;
  }
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> login(String email, String password, bool rememberMe) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final user = UserModel.fromJson(response.data['user']);
      final accessToken = response.data['accessToken'];

      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'user', value: jsonEncode(user));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', rememberMe);
      if (rememberMe) {
        await prefs.setString('email', email);
      } else {
        await prefs.remove('email');
      }
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}