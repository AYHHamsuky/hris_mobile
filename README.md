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
| Push notifications (FCM) | ⏳ next iteration |

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

## Roadmap

- FCM push notifications
- Offline draft cache for inspections (Hive)
- Biometric unlock on app start
- Line manager team-leave queue
- Push notifications deep-link into a specific task / leave application
