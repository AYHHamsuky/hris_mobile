/// Build-time configuration. Override with --dart-define=API_BASE_URL=...
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kadunaelectric.cloud/api/v1',
  );

  /// Mobile app version reported to the server when registering an FCM token.
  static const String appVersion = '1.0.0';
}
