import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/login_response.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/services/api_service.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

final isLoggingOutProvider = StateProvider<bool>((ref) => false);

final authStateProvider = StateNotifierProvider<AuthStateNotifier, UserModel?>((
  ref,
) {
  return AuthStateNotifier(ref.read(authRepositoryProvider), ref);
});

class AuthStateNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthStateNotifier(this._authRepository, this._ref) : super(null) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userFromStorage = await _authRepository.getCurrentUser();
    if (userFromStorage != null) {
      state = userFromStorage;
      try {
        final freshUser = await _authRepository.fetchAndStoreUserDetails();
        state = freshUser;
      } catch (e) {
        // Failed to refresh, proceed with stale data from storage
      }
    }
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    state = await _authRepository.login(email, password, rememberMe);
  }

  Future<void> logout() async {
    _ref.read(isLoggingOutProvider.notifier).state = true;
    try {
      await _authRepository.logout();
      _ref.read(currentChurchProvider.notifier).selectChurch(null);
      state = null;
    } finally {
      _ref.read(isLoggingOutProvider.notifier).state = false;
    }
  }

  void updateUser(UserModel user) {
    state = user;
  }
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<UserModel> login(
    String email,
    String password,
    bool rememberMe,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('accessToken', loginResponse.accessToken);
      await prefs.setString('refreshToken', loginResponse.refreshToken);

      await prefs.setBool('rememberMe', rememberMe);
      if (rememberMe) {
        await prefs.setString('email', email);
      } else {
        await prefs.remove('email');
      }

      await prefs.setString(
        'user',
        jsonEncode(loginResponse.user.toJson()),
      );

      return loginResponse.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      // Keep rememberMe and email if set
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      final email = prefs.getString('email');
      
      await prefs.clear();
      
      if (rememberMe) {
        await prefs.setBool('rememberMe', true);
        if (email != null) {
          await prefs.setString('email', email);
        }
      }
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<UserModel> fetchAndStoreUserDetails() async {
    final user = await me();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    return user;
  }

  Future<UserModel> me() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
