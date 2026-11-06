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

## Run on a physical Android device with the local backend

The local `firebase.local.json` can define the Firebase web OAuth client ID and
the service URLs. For a USB-connected phone, use `127.0.0.1` in those service
URLs and create an ADB reverse tunnel for every backend service port before
launching Flutter:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
5001..5005 | ForEach-Object { & $adb reverse "tcp:$_" "tcp:$_" }
flutter run --dart-define-from-file=firebase.local.json --android-project-arg=kotlin.incremental=false
```

This forwards User (5001), Chat (5002), Forum (5003), AI (5004), and Admin
(5005) API traffic from the physical device to the local backend. Repeat the
ADB reverse command after reconnecting the device or restarting ADB. The sample
URLs in `firebase.local.json.example` use `10.0.2.2`, which is for Android
Emulators; the ignored local file used for the connected phone uses
`127.0.0.1`.

Cloud Storage rules are in `firebase/storage.rules`. The Firebase project must
have a default Storage bucket before the rules can be deployed; the current
project does not have one yet.
