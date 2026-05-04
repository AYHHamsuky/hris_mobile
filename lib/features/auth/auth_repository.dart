import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';

class AuthUser {
  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.mustChangePassword,
    this.photoUrl,
    this.payrollId,
    this.department,
    this.position,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool mustChangePassword;
  final String? photoUrl;
  final String? payrollId;
  final String? department;
  final String? position;

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as int,
        name: j['name'] as String,
        email: j['email'] as String? ?? '',
        role: j['role'] as String? ?? 'user',
        mustChangePassword: j['must_change_password'] as bool? ?? false,
        photoUrl: j['photo_url'] as String?,
        payrollId: (j['employee'] as Map?)?['payroll_id'] as String?,
        department: (j['employee'] as Map?)?['department'] as String?,
        position: (j['employee'] as Map?)?['position'] as String?,
      );

  bool get isAdmin => role == 'admin' || role == 'super_admin';
}

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final SecureStorage _storage;

  Future<AuthUser> login({
    required String identifier,
    required String password,
    String? deviceName,
  }) async {
    final resp = await _api.dio.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
      if (deviceName != null) 'device_name': deviceName,
    });
    final token = resp.data['token'] as String;
    await _storage.setToken(token);
    return AuthUser.fromJson(resp.data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> me() async {
    final resp = await _api.dio.get('/me');
    return AuthUser.fromJson(resp.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // Even if the request fails, clear local token.
    }
    await _storage.clearToken();
  }

  Future<void> changePassword({
    String? currentPassword,
    required String password,
  }) async {
    await _api.dio.post('/profile/change-password', data: {
      if (currentPassword != null) 'current_password': currentPassword,
      'password': password,
      'password_confirmation': password,
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider), ref.read(secureStorageProvider));
});

/// Holds the current logged-in user. null = not logged in.
class AuthState {
  AuthState({this.user, this.loading = false, this.error});
  final AuthUser? user;
  final bool loading;
  final String? error;

  AuthState copyWith({AuthUser? user, bool? loading, String? error, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(AuthState());
  final AuthRepository _repo;

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true);
    try {
      final user = await _repo.me();
      state = AuthState(user: user);
    } catch (_) {
      state = AuthState();
    }
  }

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _repo.login(identifier: identifier, password: password);
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: ApiClient.describeError(e));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthState();
  }

  Future<void> markPasswordChanged() async {
    if (state.user == null) return;
    state = AuthState(
      user: AuthUser(
        id: state.user!.id,
        name: state.user!.name,
        email: state.user!.email,
        role: state.user!.role,
        mustChangePassword: false,
        photoUrl: state.user!.photoUrl,
        payrollId: state.user!.payrollId,
        department: state.user!.department,
        position: state.user!.position,
      ),
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});
