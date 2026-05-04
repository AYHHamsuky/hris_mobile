import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps local_auth so the rest of the app doesn't import the package directly.
/// Stores a single "biometric_enabled" flag in SharedPreferences.
class BiometricService {
  final _local = LocalAuthentication();
  static const _enabledKey = 'biometric_enabled';

  Future<bool> get supported async {
    try {
      return await _local.canCheckBiometrics && await _local.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_enabledKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_enabledKey, value);
  }

  /// Prompt for biometric. Returns true if authenticated, false if cancelled
  /// or unavailable (so callers can fall back to letting the user in).
  Future<bool> authenticate({String reason = 'Sign in to Kaduna Electric HRIS'}) async {
    try {
      return await _local.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (e) {
      debugPrint('BiometricService: $e');
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((_) => BiometricService());
