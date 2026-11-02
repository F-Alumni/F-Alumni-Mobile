# Firebase setup

Firebase API keys are intentionally kept out of source control. Copy
`firebase.local.json.example` to `firebase.local.json`, fill in the platform
API keys from your Firebase project, and run Flutter with:

```powershell
flutter run --dart-define-from-file=firebase.local.json
```

The local file is ignored by Git. If no keys are supplied, the app starts
without Firebase push notifications. Firebase API keys are client identifiers;
restrict them in Google Cloud Console to the app's supported APIs and app IDs.
