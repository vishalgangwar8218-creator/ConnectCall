# ConnectCall
**Connect with anyone, anywhere.**

A 1-to-1 audio/video calling application built with Flutter, developed as part of the Flutter Development Intern assignment.

---
# Demo video: https://github.com/user-attachments/assets/654182ec-e7c4-4a89-a695-12ab7d236049

## Download
[Download APK (v1.0.0)](https://github.com/vishalgangwar8218-creator/ConnectCall/releases/download/v1.0.0/app-release.apk)

## Project Description

ConnectCall is a functional 1-to-1 calling app that lets users sign up, view a live list of contacts, and place/receive real audio and video calls — complete with mute, camera toggle, camera switching, call accept/reject, and a persistent call history. It is built to demonstrate real Flutter development: UI, navigation, state management, backend integration, and real-time communication — not just a static UI prototype.

## Features

- **Authentication** — Email/password sign up, login, and logout (Firebase Authentication)
- **Contacts** — Live-updating list of all registered users with online/offline status and a search bar
- **Calling**
  - 1-to-1 audio calls
  - 1-to-1 video calls
  - Incoming call ringing (works even in background/terminated app states)
  - Accept / Reject
  - End call
- **Call Controls**
  - Audio: Mute/unmute, speaker on/off, end call
  - Video: Mute/unmute, camera on/off, switch front/rear camera, end call
- **Call History** — Every call is logged to Firestore with caller/callee, type, time, duration, and status (missed/rejected/ended)
- **Profile** — Edit display name, upload/change profile photo, logout
- **Bonus** — Light/Dark theme support (follows system setting)
- **Error & Permission Handling** — Graceful handling of denied/permanently-denied camera & microphone permissions, offline callee detection, network errors surfaced via snackbars instead of crashes

## Tech Stack

| Layer | Choice | Why |
|---|---|---|
| **Framework** | Flutter (Dart) | Required by the assignment |
| **State Management** | Provider | Simple, lightweight `ChangeNotifier`-based state for auth status; easy to explain and reason about for an app this size |
| **Backend / Database** | Firebase Auth + Cloud Firestore | Real authentication and a live, reactive database — no custom backend needed, matches "simple backend is sufficient" guidance |
| **Calling SDK** | [ZEGOCLOUD](https://www.zegocloud.com/) (`zego_uikit_prebuilt_call`) | Prebuilt invitation system handles ringing, accept/reject, and background/terminated-state call notifications out of the box — lets development time go into app architecture and UX instead of raw WebRTC signaling |
| **Image Hosting** | [Cloudinary](https://cloudinary.com/) (unsigned upload preset) | Firebase Storage now requires a Blaze (billing) account even for free-tier usage; Cloudinary's free tier needs no card and works well for simple profile-photo uploads |

## Flutter Version

- Flutter: `3.44.6` (stable channel)
- Dart SDK: `>=3.2.0 <4.0.0`

## Packages Used

```yaml
provider: ^6.1.2                       # State management
firebase_core: ^3.6.0                  # Firebase initialization
firebase_auth: ^5.3.1                  # Authentication
cloud_firestore: ^5.4.4                # Users + call history database
zego_uikit_prebuilt_call: ^4.22.3      # Calling SDK (audio/video + invitations)
permission_handler: ^12.0.3            # Runtime camera/microphone permissions
http: ^1.2.2                           # Cloudinary upload requests
image_picker: ^1.1.2                   # Pick profile photo from gallery/camera
intl: ^0.19.0                          # Date/time formatting in call history
connectivity_plus: ^6.0.5              # Network-status detection for error handling
cached_network_image: ^3.4.1           # Efficient avatar/image loading
```

## Architecture

```
lib/
├── core/
│   ├── constants/app_constants.dart    # App name, ZEGOCLOUD keys, Firestore collection names
│   └── theme/app_theme.dart            # Light/dark theme definitions
├── models/
│   ├── user_model.dart                 # User data model
│   └── call_model.dart                 # Call history record model
├── services/                           # All business logic lives here, kept out of the UI
│   ├── auth_service.dart               # Firebase Auth wrapper (ChangeNotifier)
│   ├── user_service.dart               # Firestore contacts/profile + Cloudinary photo upload
│   └── calling_service.dart            # ZEGOCLOUD call invites + call history writes
├── screens/
│   ├── splash/                         # Splash screen, routes to Login or Home
│   ├── auth/                           # Login, Register
│   ├── home/                           # Bottom nav shell (Contacts / Calls / Profile)
│   ├── contacts/                       # Contact list, search, permission-gated call buttons
│   ├── profile/                        # View/edit profile, photo upload, logout
│   ├── call/                           # Audio/Video call screens (ZEGOCLOUD config), custom incoming-call UI
│   └── history/                        # Call history list
├── widgets/                            # Reusable UI: user_tile, call_button, common_button
└── main.dart                           # App entry point, Firebase + ZEGOCLOUD invitation service setup
```

**Why this structure:** UI (`screens/`, `widgets/`) never talks to Firebase or ZEGOCLOUD directly — everything goes through `services/`. This keeps business logic testable and swappable (e.g. the Cloudinary upload could be swapped for another provider by only touching `user_service.dart`).

## Backend Used

**Firebase**
- **Authentication** — email/password sign-up and login
- **Cloud Firestore** — two collections:
  - `users` — profile info, online status, last seen
  - `calls` — call history records (caller, callee, type, status, duration, timestamp)

## Calling SDK Used — ZEGOCLOUD

Chosen over raw WebRTC because its **prebuilt invitation service** (`ZegoUIKitPrebuiltCallInvitationService`) already implements ringing, accept/reject, and incoming-call handling even when the app is backgrounded or terminated — without needing a custom signaling server. This let development focus on app architecture, UI/UX, and error handling rather than re-implementing signaling from scratch. The free tier is generous enough for development and testing.

## Setup Instructions

### 1. Prerequisites
- Flutter SDK installed (`flutter doctor` should show no blocking issues)
- An Android device/emulator (min SDK 21+)

### 2. Clone & install dependencies
```bash
git clone <your-repo-url>
cd connectcall
flutter pub get
```

### 3. Firebase setup
1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication → Email/Password**
3. Enable **Firestore Database** (start in test mode for development)
4. Run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` — required for the app to build, and intentionally **not committed** to this repo (see `.gitignore`).

### 4. ZEGOCLOUD setup
1. Create a free project at [console.zegocloud.com](https://console.zegocloud.com) (Voice & Video Call SDK)
2. Copy your **AppID** and **AppSign**
3. Paste them into `lib/core/constants/app_constants.dart`:
   ```dart
   static const int zegoAppId = <YOUR_APP_ID>;
   static const String zegoAppSign = '<YOUR_APP_SIGN>';
   ```

### 5. Cloudinary setup (for profile photo uploads)
1. Create a free account at [cloudinary.com](https://cloudinary.com)
2. Copy your **Cloud Name** from the dashboard
3. Create an **unsigned** upload preset: Settings (⚙️) → Upload → Add upload preset → Signing Mode = *Unsigned*
4. Paste both into `lib/services/user_service.dart`:
   ```dart
   static const String _cloudinaryCloudName = '<YOUR_CLOUD_NAME>';
   static const String _cloudinaryUploadPreset = '<YOUR_UPLOAD_PRESET>';
   ```

### 6. Android permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```

### 7. Run
```bash
flutter run
```
Test calling by logging in with two different accounts on two devices/emulators.

### 8. Build a release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Environment Variables / Configuration

This project does **not** use a `.env` file — configuration is done via two constant files, both excluded from version control:

| File | What it holds |
|---|---|
| `lib/firebase_options.dart` | Firebase project config (generated by `flutterfire configure`) |
| `lib/core/constants/app_constants.dart` | ZEGOCLOUD `zegoAppId` / `zegoAppSign` |
| `lib/services/user_service.dart` | Cloudinary `_cloudinaryCloudName` / `_cloudinaryUploadPreset` |

> For a production app these should be injected via `--dart-define` or a secrets manager rather than committed as constants — kept simple here for assignment purposes.

## Known Limitations

- Call screens (`screens/call/`) wrap ZEGOCLOUD's prebuilt call UI configured to match the assignment mockup; a fully pixel-custom incoming-call screen (`incoming_call_screen.dart`) is provided separately but not wired in by default — the app relies on ZEGOCLOUD's own built-in ringing UI, which already satisfies the functional requirement (including background/terminated-state ringing).
- No group calling, screen sharing, or call recording (listed as bonus features in the assignment; not implemented).
- No push notifications beyond what ZEGOCLOUD's invitation service provides natively.
- Cloudinary upload preset is unsigned for simplicity — fine for an assignment/demo, but a production app should sign uploads server-side to prevent abuse.
- Firestore security rules are left in test mode for development; production use would need proper rules scoped to authenticated users.

## AI Tools Used

AI-assisted development was used throughout this project, primarily **Claude** (Anthropic), for:
- Scaffolding the initial project structure and boilerplate (models, services, screens, widgets)
- Debugging Gradle/AGP version conflicts and ZEGOCLOUD dependency-resolution errors
- Working through Firebase Storage's new billing requirement and migrating to a Cloudinary-based upload flow
- General code review and explanation of the ZEGOCLOUD prebuilt call API

All generated code was reviewed, tested on-device, and understood before being committed.

---

**Author:** _<Vishal Gangwar>_
