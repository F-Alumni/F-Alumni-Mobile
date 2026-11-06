# Lab 3 Architecture

## Current application

The existing Alumni Connect features use feature-first folders, repositories,
and `flutter_bloc` Cubits. Their API calls and JWT session are backed by the
existing .NET services. This Lab 3 work does not silently replace those API
contracts. Google login now also signs into Firebase; the existing backend
endpoint still receives the Google OAuth ID token and returns the API JWT.
Email/password login remains backend-only for now.
When a backend session is restored, its account ID scopes the local notification
inbox; signing out clears the active inbox and switches to an anonymous scope.

The mobile API clients target the existing User (5001), Chat (5002), Forum
(5003), AI (5004), and Admin (5005) services. Recruitment posts from the Forum
API feed the mobile Jobs list because the backend models recruitment as
`PostType=Recruitment`; personal posts use the authenticated `GET
/api/v1/posts/me` endpoint. No separate job-application endpoint is present.

## Lab 3 target boundary

Lab 3 Firebase-facing features use Riverpod for dependency injection and
ViewModel state, with Firebase SDK access isolated in service classes:

```text
View (Widget) -> Riverpod ViewModel/Notifier -> Firebase service -> Firebase SDK
```

The Firebase service implementations live in
`lib/features/lab3/data/services/`; injectable Riverpod providers live in
`lib/features/lab3/presentation/providers/`. Views must not import Firebase
packages or call Firebase SDK methods.

Existing Cubit features are retained for legacy app behavior. Lab 3 additions
use Riverpod ViewModels, including avatar upload and Remote Config UI state.
The exact three Lab 2 flows still need to be confirmed before declaring the
overall state-management migration complete.

## Firebase service responsibilities

| Service | Responsibility |
| --- | --- |
| `FirebaseAuthService` | Google sign-in through Firebase, Firebase identity state, and Firebase/Google sign-out. |
| `FirebaseStorageService` | UID-scoped image upload under `reports/{uid}/...` and `posts/{uid}/...`, progress, and download URL. |
| `AvatarUploadViewModel` | Owns image selection, upload state, and coordination between Auth and Storage services. |
| `FcmMessagingService` | FCM permission status and token, three lifecycle states, account-scoped local inbox, and allowlisted detail routing. |
| `FirebaseAnalyticsService` | Seven typed events with fixed, non-identifying parameters and Firebase user ID. |
| `FirebaseCrashlyticsService` | Fatal/non-fatal reporting, global handlers, diagnostic keys, and debug-only crash trigger. |
| `FirebaseRemoteConfigService` | Defaults, cached fetch/activate, and UI-facing banner/list parameters. |

## Configuration and unavailable Firebase

Firebase initialization is conditional on valid platform options. Firebase
service providers return `null` when Firebase has not initialized so local
development without credentials can still start. Firebase API keys are read
from the ignored `firebase.local.json` using `--dart-define-from-file`; do not
commit that file or service account credentials.

Required local configuration keys are documented in
`firebase.local.json.example`. Android also needs the Firebase-generated
`android/app/google-services.json` file, which is ignored by Git.

## Remaining integration decisions

- Confirm the three assumed flows in `docs/analytics-plan.md` against the Lab 2 handoff.
- Confirm with the course whether all legacy Cubit features must migrate to Riverpod;
  current route protection still uses the backend AuthCubit, synchronized with
  Firebase sign-out changes for Google-authenticated sessions.
- Configure Firebase Console services, Android fingerprints, and Storage rules.
- Verify Storage rules in the Firebase Emulator/Console; uploads are limited to
  the signed-in UID's own `reports/` or `posts/` folder (10 MB maximum). Authenticated
  users can read post images; report images are readable by their owner only.
- Verify that Firebase Messaging Console test sends reach the configured device.
