import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage so the rest of the app doesn't import the
/// vendor package directly. Stores the Sanctum token only — no PII.
class SecureStorage {
  SecureStorage._();
  static final SecureStorage _instance = SecureStorage._();
  factory SecureStorage() => _instance;

  final _store = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kToken = 'auth_token';

  Future<void> setToken(String token) => _store.write(key: _kToken, value: token);
  Future<String?> getToken() => _store.read(key: _kToken);
  Future<void> clearToken() => _store.delete(key: _kToken);
}
