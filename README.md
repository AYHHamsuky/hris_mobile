# Kaduna Electric HRIS — Staff Mobile Companion

Flutter app (iOS + Android) that talks to the Laravel HRIS backend at
`https://kadunaelectric.cloud/api/v1`.

## What's inside

| Feature | Status |
|---|---|
| Sanctum login (email or Payroll ID) + biometric ready | ✅ |
| First-login force-change-password flow | ✅ |
| Dashboard (tasks/projects/leave summary) | ✅ |
| Tasks list + detail + Odoo state changes + comments | ✅ |
| Projects list | ✅ |
| Leave: balances + applications + apply form | ✅ |
| Field Inspections: GPS, OSM map, camera/gallery/files, weather, progress | ✅ |
| Profile + sign out + change password | ✅ |
| Push notifications (FCM) | ✅ scaffolded — needs Firebase config |
| Offline draft cache for inspections | ✅ shared_preferences-backed, auto-syncs |
| Line manager Team Leave queue + LM approve/reject | ✅ |
| Biometric unlock at app start | ✅ |
| Project detail page (tasks grouped by Odoo state + milestones) | ✅ |
| Task comments + attachments + progress slider on detail page | ✅ |
| Branded launcher icon + native splash screen | ✅ |
| GitHub Actions CI (analyze, test, build APK on tag) | ✅ |
| Notifications inbox + bell badge on Dashboard | ✅ |
| Signed Android APK / Play Store .aab pipeline | ✅ (needs keystore secrets) |
| iOS background-modes for push delivery | ✅ |

## Architecture

- **State**: `flutter_riverpod`
- **HTTP**: `dio` with bearer-token interceptor
- **Routing**: `go_router` with shell route + bottom nav
- **Secure storage**: `flutter_secure_storage` (Sanctum token only)
- **Map**: `flutter_map` + OpenStreetMap tiles (no API key)
- **GPS**: `geolocator` with high accuracy
- **Media**: `image_picker` + `file_picker`

## Folder layout

```
lib/
├── main.dart                          # ProviderScope + MaterialApp.router
├── app/
│   ├── env.dart                       # API_BASE_URL build-time var
│   ├── theme.dart
│   ├── router.dart                    # go_router config
│   └── main_shell.dart                # Bottom-nav scaffold
├── core/
│   ├── api/api_client.dart            # Dio + auth interceptor + error helper
│   └── storage/secure_storage.dart
└── features/
    ├── auth/                          # login, change-password, AuthController
    ├── dashboard/
    ├── tasks/                         # models, repo, list, detail
    ├── projects/
    ├── leave/                         # models, repo, list, apply
    ├── inspections/                   # models, repo, list, GPS form
    └── profile/
```

## Run locally

```bash
# Install deps
flutter pub get

# Connect a device or simulator
flutter devices

# Run against production API (default)
flutter run

# Run against staging or a local Laravel dev server
flutter run --dart-define=API_BASE_URL=https://staging.kadunaelectric.cloud/api/v1
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1   # Android emulator → host
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1  # iOS simulator
```

## Build for release

```bash
# Android signed APK
flutter build apk --release \
  --dart-define=API_BASE_URL=https://kadunaelectric.cloud/api/v1

# iOS (needs Xcode + Apple Developer account)
flutter build ios --release \
  --dart-define=API_BASE_URL=https://kadunaelectric.cloud/api/v1
```

## Backend dependency

Requires the Laravel HRIS backend with the `/api/v1/*` routes from commit
`81bf124` and Sanctum installed. See `app/Http/Controllers/Api/V1/`
in the HRIS repo.

## Permissions

| Permission | Why |
|---|---|
| Internet | Talk to the HRIS API |
| Location (fine) | GPS auto-capture for Field Inspections |
| Camera | Snap photos / video for inspections |
| Microphone | Record audio notes for inspections |
| Photo library / external storage | Pick existing media for upload |

All declared in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.

## Push notification setup

The app is wired for FCM but needs your Firebase project to actually deliver
notifications:

1. Create a Firebase project (or use the existing Kaduna Electric one).
2. Add an Android app: package name `cloud.kadunaelectric.hris_mobile`.
   Download `google-services.json` → drop it in `android/app/`.
3. Add an iOS app: bundle id matches the iOS target; download
   `GoogleService-Info.plist` → drag it into `ios/Runner/` from Xcode.
4. On the Laravel side, set `FCM_SERVER_KEY` in `.env` to the Cloud Messaging
   Server Key (Project Settings → Cloud Messaging → Server key, Legacy API).

If `FCM_SERVER_KEY` is unset on the backend or the config files are missing
on the client, the app falls back to silent no-ops — nothing else breaks.

## Releasing a signed Android build

The CI workflow at `.github/workflows/ci.yml` already builds an unsigned
release APK on every push to `main` and uploads it as a workflow artifact,
plus attaches it to a GitHub Release whenever you push a tag like `v1.0.1`.

To produce a *signed* APK suitable for the Play Store:

1. Generate a keystore once and upload it as a GitHub secret:
   ```
   keytool -genkey -v -keystore release.keystore -alias hris -keyalg RSA -keysize 2048 -validity 10000
   base64 -i release.keystore | pbcopy           # copy to clipboard
   ```
2. In GitHub → Settings → Secrets and variables → Actions, add:
   - `ANDROID_KEYSTORE_BASE64` (the base64 blob)
   - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`
3. Update `android/app/build.gradle` with a signingConfig block that reads
   from `android/key.properties` and adjust the workflow to write that file
   from the secrets before `flutter build apk --release`.

Until then, install the unsigned APK on test devices with:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Branding

Launcher icon + splash are generated from `assets/branding/`:
- `app_icon.png` (1024×1024) → all Android mipmap densities + iOS AppIcon
- `splash_logo.png` (1024×1024) → Android 11/12+ splash, iOS LaunchImage

Re-run after replacing the source PNGs:
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Roadmap

- Signed APK pipeline (see above)
- iOS TestFlight build (needs Apple Developer account)
- Pull-to-refresh feedback unification
- Localisation (en + Hausa)
