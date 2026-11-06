# Lab 3 Architecture — MVVM Integration & Firebase Boundaries

## 1. Overview and Design Philosophy

The Alumni Connect application employs a clean, layered architectural boundary separating the UI Presentation, State Management (Riverpod ViewModels / BLoC Cubits), Domain Repositories, Service Layer, and the underlying Firebase SDKs.

```text
[ View (UI Widget) ] 
       │ ▲
       ▼ │ (UI State: Loading / Content / Empty / Error)
[ ViewModel / Riverpod Notifier ]
       │ ▲
       ▼ │ (DTOs / Business Domain Logic)
[ Service Layer (Abstraction) ]
       │ ▲
       ▼ │ (Firebase APIs & Handlers)
[ Firebase SDK ]
```

**Strict MVVM Principle:** Views (Flutter Widgets) NEVER directly import Firebase SDKs or execute Firebase API calls. All cloud operations are mediated through abstract service contracts exposed via Riverpod providers.

---

## 2. Service Layer Responsibilities

| Service | File Location | Responsibility |
| :--- | :--- | :--- |
| `FirebaseAuthService` | `lib/features/lab3/data/services/firebase_auth_service.dart` | Handles Google Sign-In, Firebase session identity stream (`authStateChanges`), session exchange with .NET User API (5001), and secure sign-out. |
| `FirebaseStorageService` | `lib/features/lab3/data/services/firebase_storage_service.dart` | Uploads files strictly scoped to `reports/{uid}/...` and `posts/{uid}/...`. Supports images, PDF, and CSV. Emits real-time progress stream and retrieves secure download URLs. |
| `FcmMessagingService` | `lib/core/services/fcm_messaging_service.dart` | Manages Android 13+ runtime permissions (`POST_NOTIFICATIONS`), FCM token registration, lifecycle states (Foreground, Background, Terminated), local in-app inbox, and deep link routing. |
| `FirebaseAnalyticsService` | `lib/features/lab3/data/services/firebase_analytics_service.dart` | Dispatches 8 standardized product events without PII: `login`, `logout`, `search`, `select_content`, `view_item`, `avatar_upload_complete`, `export_file`, `notification_open`. Binds user via `setUserId(user.uid)`. |
| `FirebaseCrashlyticsService` | `lib/features/lab3/data/services/firebase_crashlytics_service.dart` | Captures uncaught errors globally (`FlutterError.onError`, `PlatformDispatcher.instance.onError`), logs handled non-fatal errors, sets custom diagnostic keys, and provides test crash trigger. |
| `FirebaseRemoteConfigService` | `lib/features/lab3/data/services/firebase_remote_config_service.dart` | Manages server-driven configurations with local fallback defaults (`is_promo_banner_enabled`, `max_items_display`). Features real-time activation in `kDebugMode` and hourly caching in production. |

---

## 3. Cloud Storage Security Architecture (`firebase/storage.rules`)

The cloud storage hierarchy enforces strict user-level multi-tenancy and data isolation:

```text
/b/{bucket}/o/
  ├── reports/{userId}/{fileName} -> Only owner can read/write; max 10MB; images, PDF, CSV
  └── posts/{userId}/{fileName}   -> Only owner can write; all authenticated users can read; max 10MB
```

- Unauthenticated operations are strictly rejected (`request.auth != null`).
- Path traversal and cross-tenant tampering are prevented by binding path `{userId}` to `request.auth.uid`.
- Resource size is bounded to 10MB to protect against denial-of-wallet risks.

---

## 4. UI State Representation

All interactive features reflect 4 explicit UI states:
1. **Loading State:** Circular/shimmer progress indicators during network or async I/O.
2. **Success/Content State:** Clean presentation of fetched feeds, directory lists, job cards, or profile data.
3. **Empty State:** Descriptive empty illustrations and friendly advice when filters or searches return zero items.
4. **Error State:** Human-readable error messages with retry actions, preventing app crashes and logging non-fatal diagnostics to Crashlytics.
