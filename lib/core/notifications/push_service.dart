import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/env.dart';
import '../api/api_client.dart';

/// Wraps Firebase Cloud Messaging.
///
/// Safe to call `init()` even if Firebase isn't configured yet — it logs the
/// failure and no-ops so the app still works in dev environments without a
/// google-services.json / GoogleService-Info.plist.
class PushService {
  PushService(this._api);
  final ApiClient _api;

  Future<void> init({void Function(RemoteMessage)? onMessageOpenedApp}) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (iOS shows the system dialog; Android 13+ also).
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // Foreground messages get the standard system banner on iOS via this:
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      // Get and register the token.
      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // Re-register on token refresh.
      messaging.onTokenRefresh.listen(_registerToken);

      // Handle a notification tap that opened the app from a terminated state.
      final initial = await messaging.getInitialMessage();
      if (initial != null && onMessageOpenedApp != null) {
        onMessageOpenedApp(initial);
      }

      // Handle taps while the app is backgrounded.
      if (onMessageOpenedApp != null) {
        FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
      }
    } catch (e) {
      debugPrint('PushService: init failed: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _api.dio.post('/me/device-token', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'app_version': Env.appVersion,
      });
    } catch (e) {
      debugPrint('PushService: token register failed: $e');
    }
  }

  Future<void> deregister() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _api.dio.delete('/me/device-token', data: {'token': token});
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Best-effort.
    }
  }
}

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService(ref.read(apiClientProvider));
});
